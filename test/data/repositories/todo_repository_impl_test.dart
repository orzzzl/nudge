import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nudge/data/db/app_database.dart' as db;
import 'package:nudge/data/repositories/todo_repository_impl.dart';
import 'package:nudge/domain/plan.dart';
import 'package:nudge/domain/todo.dart';
import 'package:nudge/domain/todo_repository.dart';
import 'package:nudge/l10n/generated/app_localizations_en.dart';

void main() {
  late db.AppDatabase database;
  late TodoRepository repository;

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    repository = TodoRepositoryImpl(database);
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'createTodo assigns increasing seq values without reusing deletes',
    () async {
      final first = await repository.createTodo(title: 'First task');

      await repository.deleteTodo(first.id!);
      final second = await repository.createTodo(title: 'Second task');

      expect(first.seq, 3);
      expect(second.seq, 4);
    },
  );

  test('createTodo stores permanent todos without a due date', () async {
    final todo = await repository.createTodo(
      title: 'Daily practice',
      priority: TodoPriority.permanent,
      dueDate: DateTime(2026, 6, 10, 15),
    );

    expect(todo.priority, TodoPriority.permanent);
    expect(todo.dueDate, isNull);
  });

  test('getTodoById returns a domain todo or null', () async {
    final todo = await repository.createTodo(title: 'Find me');

    expect(await repository.getTodoById(todo.id!), todo);
    expect(await repository.getTodoById(999), isNull);
  });

  test('updateTodo updates fields and can clear nullable fields', () async {
    final todo = await repository.createTodo(
      title: 'Draft',
      dueDate: DateTime(2026, 6, 10, 12),
    );

    await repository.updateTodo(
      id: todo.id!,
      title: 'Published',
      status: TodoStatus.inProgress,
      priority: TodoPriority.p0,
      dueDate: DateTime(2026, 6, 12, 18),
      note: 'Polish the final section',
    );
    final updated = await repository.getTodoById(todo.id!);

    expect(updated, isNotNull);
    expect(updated!.title, 'Published');
    expect(updated.status, TodoStatus.inProgress);
    expect(updated.priority, TodoPriority.p0);
    expect(updated.dueDate, DateTime(2026, 6, 12));
    expect(updated.note, 'Polish the final section');

    await repository.updateTodo(
      id: todo.id!,
      clearDueDate: true,
      clearNote: true,
    );
    final cleared = await repository.getTodoById(todo.id!);

    expect(cleared!.dueDate, isNull);
    expect(cleared.note, isNull);

    await repository.updateTodo(
      id: todo.id!,
      priority: TodoPriority.permanent,
      dueDate: DateTime(2026, 6, 20),
    );
    final permanent = await repository.getTodoById(todo.id!);

    expect(permanent!.priority, TodoPriority.permanent);
    expect(permanent.dueDate, isNull);
  });

  test('watchTodos emits changes', () async {
    final localizations = AppLocalizationsEn();
    final initial = await repository.watchTodos().first;
    expect(initial.map((todo) => todo.title), [
      localizations.todoSeedEatTitle,
      localizations.todoSeedSleepTitle,
    ]);

    final titlesStream = repository.watchTodos().map((todos) {
      return todos.map((todo) => todo.title).toList(growable: false);
    });
    final expectation = expectLater(
      titlesStream,
      emitsThrough(
        predicate<List<String>>(
          (titles) => titles.contains('Emitted task'),
          'contains the created todo',
        ),
      ),
    );

    await repository.createTodo(title: 'Emitted task');

    await expectation;
  });

  test('watchTodos returns the selected flat list order', () async {
    final localizations = AppLocalizationsEn();
    await repository.createTodo(title: 'P2 no due');
    await repository.createTodo(title: 'P1 no due', priority: TodoPriority.p1);
    await repository.createTodo(
      title: 'P1 due soon',
      priority: TodoPriority.p1,
      dueDate: DateTime(2026, 6, 2),
    );
    await repository.createTodo(
      title: 'P0 due later',
      priority: TodoPriority.p0,
      dueDate: DateTime(2026, 6, 3),
    );
    await repository.createTodo(
      title: 'Always',
      priority: TodoPriority.permanent,
    );
    final archiveOlder = await repository.createTodo(title: 'Archive older');
    final archiveNewer = await repository.createTodo(title: 'Archive newer');
    await repository.updateTodo(id: archiveOlder.id!, status: TodoStatus.done);
    await Future<void>.delayed(const Duration(milliseconds: 1));
    await repository.updateTodo(
      id: archiveNewer.id!,
      status: TodoStatus.dropped,
    );

    final todos = await repository.watchTodos().first;

    expect(todos.map((todo) => todo.title), [
      'P0 due later',
      'P1 due soon',
      'P1 no due',
      'P2 no due',
      localizations.todoSeedEatTitle,
      localizations.todoSeedSleepTitle,
      'Always',
      'Archive newer',
      'Archive older',
    ]);
  });

  test('addLog and watchLogs keep chronological order', () async {
    final todo = await repository.createTodo(title: 'Logged task');
    expect(await repository.watchLogs(todo.id!).first, isEmpty);

    await repository.addLog(
      todoId: todo.id!,
      text: 'First log',
      kind: TodoLogKind.manual,
    );
    final firstLogs = await repository.watchLogs(todo.id!).first;
    expect(firstLogs.map((log) => log.text), ['First log']);

    await Future<void>.delayed(const Duration(milliseconds: 1));
    await repository.addLog(
      todoId: todo.id!,
      text: 'Second log',
      kind: TodoLogKind.auto,
    );
    final allLogs = await repository.watchLogs(todo.id!).first;

    expect(allLogs.map((log) => log.text), ['First log', 'Second log']);
    expect(allLogs.map((log) => log.kind), [
      TodoLogKind.manual,
      TodoLogKind.auto,
    ]);
  });

  test('deleteTodo cascades logs and clears linked plans', () async {
    final todo = await repository.createTodo(title: 'Linked task');
    await repository.addLog(
      todoId: todo.id!,
      text: 'Progress log',
      kind: TodoLogKind.manual,
    );
    final planId = await database.plansDao.insertPlan(
      db.PlansCompanion.insert(
        todoId: drift.Value(todo.id),
        title: 'Linked plan',
        durationSec: 60,
        startAt: _day,
        endAt: _day.add(const Duration(minutes: 1)),
        status: drift.Value(PlanStatus.running.name),
        locale: const drift.Value('en'),
        createdAt: _day,
      ),
    );

    await repository.deleteTodo(todo.id!);

    expect(await repository.getTodoById(todo.id!), isNull);
    expect(await repository.watchLogs(todo.id!).first, isEmpty);
    expect((await database.plansDao.getPlanById(planId))!.todoId, isNull);
  });

  test('unknown enum values throw StateError when mapped', () async {
    final todo = await repository.createTodo(title: 'Bad enum');
    await database.todosDao.updateTodoById(
      id: todo.id!,
      todo: const db.TodosCompanion(status: drift.Value('mystery')),
    );

    await expectLater(
      repository.getTodoById(todo.id!),
      throwsA(isA<StateError>()),
    );
  });
}

final _day = DateTime(2026, 6, 1, 9);
