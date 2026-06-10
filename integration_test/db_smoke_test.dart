import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nudge/data/db/app_database.dart';
import 'package:nudge/data/repositories/plan_repository_impl.dart';
import 'package:nudge/data/repositories/todo_repository_impl.dart';
import 'package:nudge/domain/plan.dart';
import 'package:nudge/domain/plan_repository.dart';
import 'package:nudge/domain/todo.dart';
import 'package:nudge/domain/todo_repository.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // The native XCTest runner enables iOS accessibility while the test is
  // running. That opens Flutter's platform-owned SemanticsHandle after
  // testWidgets has recorded its baseline, so flutter_test reports a leak even
  // though the app code did not create one. Pin the test dispatcher to
  // semantics-on before testWidgets records its baseline; the platform-owned
  // handle is then part of the expected count for this non-UI smoke test.
  binding.platformDispatcher.semanticsEnabledTestValue = true;

  late AppDatabase database;
  late PlanRepository repository;

  setUp(() {
    database = AppDatabase();
    repository = PlanRepositoryImpl(database.plansDao);
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('round-trips a plan through the on-device database', (_) async {
    final startAt = DateTime.now();

    final plan = await repository.createPlan(
      title: 'smoke',
      durationSec: 30 * 60,
      startAt: startAt,
      locale: 'en',
    );

    expect(plan.id, isNotNull);

    final id = plan.id!;
    final storedPlan = await repository.getPlanById(id);

    expect(storedPlan, isNotNull);
    expect(storedPlan!.title, 'smoke');
    expect(storedPlan.durationSec, 30 * 60);
    expect(storedPlan.status, PlanStatus.running);

    await repository.checkIn(id: id, status: PlanStatus.done);

    final checkedInPlan = await repository.getPlanById(id);

    expect(checkedInPlan, isNotNull);
    expect(checkedInPlan!.status, PlanStatus.done);
  });

  testWidgets('round-trips a todo through the on-device database', (_) async {
    final TodoRepository todoRepository = TodoRepositoryImpl(database);

    // Opening the real database ran the v3 onCreate path on this device,
    // including the permanent seed items — assert them instead of letting a
    // failed seed hide behind a green plan round-trip.
    final seeded = await todoRepository.watchTodos().first;
    expect(
      seeded
          .where((todo) => todo.priority == TodoPriority.permanent)
          .map((todo) => todo.seq),
      containsAll(<int>[1, 2]),
    );

    final todo = await todoRepository.createTodo(
      title: 'smoke todo',
      priority: TodoPriority.p1,
      dueDate: DateTime(2026, 6, 15),
      note: 'smoke note',
    );
    expect(todo.id, isNotNull);

    final id = todo.id!;
    await todoRepository.updateTodo(
      id: id,
      title: 'smoke todo edited',
      status: TodoStatus.inProgress,
    );

    final updated = await todoRepository.getTodoById(id);
    expect(updated, isNotNull);
    expect(updated!.title, 'smoke todo edited');
    expect(updated.status, TodoStatus.inProgress);
    expect(updated.note, 'smoke note');

    await todoRepository.addLog(
      todoId: id,
      text: 'smoke progress',
      kind: TodoLogKind.manual,
    );
    final logs = await todoRepository.watchLogs(id).first;
    expect(logs.map((log) => log.text), ['smoke progress']);

    final linkedPlan = await repository.createPlan(
      todoId: id,
      title: 'linked plan',
      durationSec: 60,
      startAt: DateTime.now(),
      locale: 'en',
    );
    expect(linkedPlan.todoId, id);

    // Delete must cascade in one transaction: logs go, the linked plan is
    // unlinked but kept. Transaction + foreign-key behaviour is exactly the
    // kind of thing the on-device native sqlite3 path can do differently from
    // the host sqlite3 the unit tests run on.
    await todoRepository.deleteTodo(id);

    expect(await todoRepository.getTodoById(id), isNull);
    expect(await todoRepository.watchLogs(id).first, isEmpty);

    final unlinkedPlan = await repository.getPlanById(linkedPlan.id!);
    expect(unlinkedPlan, isNotNull);
    expect(unlinkedPlan!.todoId, isNull);
  });
}
