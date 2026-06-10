import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nudge/app/providers.dart';
import 'package:nudge/domain/todo.dart';
import 'package:nudge/domain/todo_repository.dart';
import 'package:nudge/features/todos/todo_edit_screen.dart';
import 'package:nudge/l10n/generated/app_localizations.dart';
import 'package:nudge/l10n/generated/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();
  late _RecordingTodoRepository repository;

  setUp(() => repository = _RecordingTodoRepository());
  tearDown(() => repository.dispose());

  Future<void> pumpEdit(WidgetTester tester, {Todo? initial}) async {
    late final GoRouter router;
    router = GoRouter(
      initialLocation: '/start',
      routes: [
        GoRoute(
          path: '/start',
          builder: (_, _) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => router.push('/todos/new'),
                child: const Text('go'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/todos/new',
          builder: (_, _) => TodoEditScreen(initial: initial),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [todoRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
  }

  testWidgets('fills the form and creates a todo, then pops back', (
    tester,
  ) async {
    await pumpEdit(tester);
    expect(find.byKey(const Key('todoEditScreen')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('todoTitleField')),
      'Read paper',
    );
    await tester.tap(find.text('P0'));
    await tester.tap(find.text(l10n.todoDueTomorrow));
    await tester.enterText(find.byKey(const Key('todoNoteField')), 'chapter 3');
    await tester.pump();

    await tester.tap(find.text('＋ ${l10n.todoCreateButton}'));
    await tester.pumpAndSettle();

    final created = repository.created!;
    expect(created.title, 'Read paper');
    expect(created.priority, TodoPriority.p0);
    expect(created.note, 'chapter 3');
    final tomorrow = _today().add(const Duration(days: 1));
    expect(created.dueDate, tomorrow);

    // Popped back off the edit screen.
    expect(find.byKey(const Key('todoEditScreen')), findsNothing);
  });

  testWidgets('an empty title shows a reminder and does not create', (
    tester,
  ) async {
    await pumpEdit(tester);

    await tester.tap(find.text('＋ ${l10n.todoCreateButton}'));
    await tester.pump();

    expect(repository.created, isNull);
    expect(find.text(l10n.todoNeedTitle), findsOneWidget);
    expect(find.byKey(const Key('todoEditScreen')), findsOneWidget);
  });

  testWidgets('choosing permanent hides the due picker and stores null due', (
    tester,
  ) async {
    await pumpEdit(tester);

    // Pick a due date first, then switch to permanent.
    await tester.tap(find.text(l10n.todoDueTomorrow));
    await tester.pump();
    expect(find.text(l10n.todoFormDueLabel), findsOneWidget);

    await tester.tap(find.text('♾️ ${l10n.todoPriorityPermanent}'));
    await tester.pump();
    expect(find.text(l10n.todoFormDueLabel), findsNothing);

    await tester.enterText(find.byKey(const Key('todoTitleField')), 'Sleep');
    await tester.tap(find.text('＋ ${l10n.todoCreateButton}'));
    await tester.pumpAndSettle();

    expect(repository.created!.priority, TodoPriority.permanent);
    expect(repository.created!.dueDate, isNull);
  });

  testWidgets('edit mode prefills the form from the initial todo', (
    tester,
  ) async {
    await pumpEdit(
      tester,
      initial: Todo(
        id: 3,
        seq: 3,
        title: 'Existing',
        status: TodoStatus.notStarted,
        priority: TodoPriority.p1,
        dueDate: null,
        note: 'old note',
        createdAt: DateTime(2026, 6, 1),
        updatedAt: DateTime(2026, 6, 1),
      ),
    );

    expect(find.text('Existing'), findsOneWidget);
    expect(find.text('old note'), findsOneWidget);

    // Edit mode must read as editing, not creating (title + action button).
    expect(find.text(l10n.todoEditItemTitle), findsOneWidget);
    expect(find.text(l10n.todoSaveButton), findsOneWidget);
    expect(find.text(l10n.todoNewItemTitle), findsNothing);
    expect(find.text('＋ ${l10n.todoCreateButton}'), findsNothing);

    // Saving updates the existing todo instead of creating a new one.
    await tester.tap(find.text(l10n.todoSaveButton));
    await tester.pump();
    expect(repository.created, isNull);
    expect(repository.updatedId, 3);
  });
}

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

class _RecordingTodoRepository implements TodoRepository {
  final _controller = StreamController<List<Todo>>.broadcast();
  List<Todo> _todos = const [];

  ({String title, TodoPriority priority, DateTime? dueDate, String? note})?
  created;
  int? updatedId;

  void dispose() => _controller.close();

  @override
  Stream<List<Todo>> watchTodos() async* {
    yield _todos;
    yield* _controller.stream;
  }

  @override
  Future<Todo> createTodo({
    required String title,
    TodoPriority priority = TodoPriority.p2,
    DateTime? dueDate,
    String? note,
  }) async {
    created = (title: title, priority: priority, dueDate: dueDate, note: note);
    final todo = Todo(
      id: 99,
      seq: 3,
      title: title,
      status: TodoStatus.notStarted,
      priority: priority,
      dueDate: dueDate,
      note: note,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _todos = [..._todos, todo];
    _controller.add(_todos);
    return todo;
  }

  @override
  Future<Todo?> getTodoById(int id) async => null;

  @override
  Future<void> updateTodo({
    required int id,
    String? title,
    TodoStatus? status,
    TodoPriority? priority,
    DateTime? dueDate,
    bool clearDueDate = false,
    String? note,
    bool clearNote = false,
  }) async {
    updatedId = id;
  }

  @override
  Future<void> deleteTodo(int id) => throw UnimplementedError();

  @override
  Stream<List<TodoLog>> watchLogs(int todoId) => throw UnimplementedError();

  @override
  Future<void> addLog({
    required int todoId,
    required String text,
    required TodoLogKind kind,
  }) => throw UnimplementedError();
}
