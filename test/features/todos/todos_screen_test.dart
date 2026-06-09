import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nudge/app/providers.dart';
import 'package:nudge/domain/todo.dart';
import 'package:nudge/domain/todo_repository.dart';
import 'package:nudge/features/todos/todo_detail_screen.dart';
import 'package:nudge/features/todos/todo_edit_screen.dart';
import 'package:nudge/features/todos/todos_controller.dart';
import 'package:nudge/features/todos/todos_screen.dart';
import 'package:nudge/l10n/generated/app_localizations.dart';
import 'package:nudge/l10n/generated/app_localizations_en.dart';

void main() {
  group('groupTodos', () {
    test('partitions into active / permanent / archived, keeping order', () {
      final todos = [
        _todo(id: 1, seq: 3, status: TodoStatus.inProgress),
        _todo(id: 2, seq: 1, priority: TodoPriority.permanent),
        _todo(id: 3, seq: 5, status: TodoStatus.done),
        _todo(id: 4, seq: 4, status: TodoStatus.notStarted),
        _todo(id: 5, seq: 6, status: TodoStatus.dropped),
      ];

      final groups = groupTodos(todos);

      expect(groups.active.map((t) => t.id), [1, 4]);
      expect(groups.permanent.map((t) => t.id), [2]);
      expect(groups.archived.map((t) => t.id), [3, 5]);
    });

    test('a done permanent stays in the permanent group', () {
      final groups = groupTodos([
        _todo(
          id: 1,
          seq: 1,
          priority: TodoPriority.permanent,
          status: TodoStatus.done,
        ),
      ]);

      expect(groups.permanent, hasLength(1));
      expect(groups.archived, isEmpty);
    });
  });

  testWidgets('renders the three sections with seq, priority and status', (
    tester,
  ) async {
    final l10n = AppLocalizationsEn();
    await _pump(tester, [
      _todo(
        id: 1,
        seq: 3,
        title: 'Write report',
        priority: TodoPriority.p0,
        status: TodoStatus.inProgress,
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
      _todo(id: 2, seq: 1, title: 'Eat', priority: TodoPriority.permanent),
      _todo(id: 3, seq: 5, title: 'Tidy desk', status: TodoStatus.done),
    ]);

    expect(find.text(l10n.todosSectionActive), findsOneWidget);
    expect(find.text('♾️ ${l10n.todosSectionPermanent}'), findsOneWidget);
    expect(find.text(l10n.todosSectionArchived), findsOneWidget);

    expect(find.text('#3'), findsOneWidget);
    expect(find.text('Write report'), findsOneWidget);
    expect(find.text('P0'), findsOneWidget);
    expect(find.text(l10n.todoStatusInProgress), findsOneWidget);

    // Permanent flag uses the localized label, archived title is struck through.
    expect(find.text(l10n.todoPriorityPermanent), findsOneWidget);
    final archivedTitle = tester.widget<Text>(find.text('Tidy desk'));
    expect(archivedTitle.style?.decoration, TextDecoration.lineThrough);
  });

  testWidgets('overdue due date is shown in the coral colour', (tester) async {
    final l10n = AppLocalizationsEn();
    await _pump(tester, [
      _todo(
        id: 1,
        seq: 3,
        title: 'Overdue task',
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ]);

    final dueText = tester.widget<Text>(
      find.textContaining(l10n.todoDueOverdue(2)),
    );
    expect((dueText.style?.color), const Color(0xFFD9745F));
  });

  testWidgets('shows the empty state when there are no todos', (tester) async {
    final l10n = AppLocalizationsEn();
    await _pump(tester, const []);

    expect(find.text(l10n.todosEmptyTitle), findsOneWidget);
  });

  testWidgets('tapping a row opens the detail route', (tester) async {
    await _pump(tester, [_todo(id: 7, seq: 3, title: 'Open me')]);

    await tester.tap(find.text('Open me'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('todoDetailScreen')), findsOneWidget);
  });

  testWidgets('the add button opens the new-item page', (tester) async {
    final l10n = AppLocalizationsEn();
    await _pump(tester, const []);

    await tester.tap(find.text('＋ ${l10n.todoAddButton}'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('todoEditScreen')), findsOneWidget);
  });
}

Future<void> _pump(WidgetTester tester, List<Todo> todos) async {
  final router = GoRouter(
    initialLocation: '/todos',
    routes: [
      GoRoute(path: '/todos', builder: (_, _) => const TodosScreen()),
      GoRoute(path: '/todos/new', builder: (_, _) => const TodoEditScreen()),
      GoRoute(
        path: '/todos/:id',
        builder: (_, state) =>
            TodoDetailScreen(todoId: int.parse(state.pathParameters['id']!)),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        todoRepositoryProvider.overrideWithValue(_FakeTodoRepository(todos)),
      ],
      child: MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Todo _todo({
  required int id,
  required int seq,
  String title = 'A task',
  TodoStatus status = TodoStatus.notStarted,
  TodoPriority priority = TodoPriority.p2,
  DateTime? dueDate,
}) {
  final now = DateTime(2026, 6, 1);
  return Todo(
    id: id,
    seq: seq,
    title: title,
    status: status,
    priority: priority,
    dueDate: dueDate,
    note: null,
    createdAt: now,
    updatedAt: now,
  );
}

class _FakeTodoRepository implements TodoRepository {
  _FakeTodoRepository(this._todos);

  final List<Todo> _todos;

  @override
  Stream<List<Todo>> watchTodos() => Stream.value(_todos);

  @override
  Future<Todo?> getTodoById(int id) async {
    for (final todo in _todos) {
      if (todo.id == id) {
        return todo;
      }
    }
    return null;
  }

  @override
  Future<Todo> createTodo({
    required String title,
    TodoPriority priority = TodoPriority.p2,
    DateTime? dueDate,
    String? note,
  }) => throw UnimplementedError();

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
  }) => throw UnimplementedError();

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
