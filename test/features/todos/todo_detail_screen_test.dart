import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nudge/app/providers.dart';
import 'package:nudge/domain/plan.dart';
import 'package:nudge/domain/todo.dart';
import 'package:nudge/domain/todo_repository.dart';
import 'package:nudge/features/chat/chat_controller.dart';
import 'package:nudge/features/chat/pending_composer_todo.dart';
import 'package:nudge/features/todos/todo_detail_screen.dart';
import 'package:nudge/features/todos/todo_edit_screen.dart';
import 'package:nudge/features/todos/widgets/todo_meta.dart';
import 'package:nudge/l10n/generated/app_localizations.dart';
import 'package:nudge/l10n/generated/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();
  late _DetailFakeRepository repository;

  setUp(() => repository = _DetailFakeRepository());
  tearDown(() => repository.dispose());

  Future<void> pumpDetail(
    WidgetTester tester,
    Todo todo, {
    Plan? activePlan,
  }) async {
    repository.todo = todo;
    late final GoRouter router;
    router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (_, _) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => router.push('/todos/${todo.id}'),
                child: const Text('go'),
              ),
            ),
          ),
        ),
        GoRoute(path: '/chat', builder: (_, _) => const _ChatProbe()),
        GoRoute(
          path: '/todos/:id/edit',
          builder: (_, state) => TodoEditScreen(initial: state.extra as Todo?),
        ),
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
          todoRepositoryProvider.overrideWithValue(repository),
          chatControllerProvider.overrideWith(
            () => _FakeChatController(activePlan),
          ),
        ],
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

  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.byTooltip(l10n.todoMoreActions));
    await tester.pumpAndSettle();
  }

  testWidgets('shows read-only title, meta and note', (tester) async {
    await pumpDetail(
      tester,
      _todo(
        seq: 3,
        title: 'Write report',
        priority: TodoPriority.p0,
        status: TodoStatus.inProgress,
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        note: 'the draft outline',
      ),
    );

    expect(find.text('#3  Write report'), findsOneWidget);
    expect(find.text('P0'), findsOneWidget);
    expect(find.text(l10n.todoStatusInProgress), findsOneWidget);
    expect(find.textContaining(l10n.todoDueOverdue(1)), findsOneWidget);
    expect(find.text('the draft outline'), findsOneWidget);
  });

  testWidgets('permanent items hide status and due', (tester) async {
    await pumpDetail(
      tester,
      _todo(
        seq: 5,
        title: 'Game time',
        priority: TodoPriority.permanent,
        dueDate: DateTime.now(),
      ),
    );

    expect(find.text('♾️ ${l10n.todoPriorityPermanent}'), findsOneWidget);
    expect(find.text(l10n.todoStatusNotStarted), findsNothing);
    expect(find.textContaining('📅'), findsNothing);
  });

  testWidgets('edit menu pushes the editor prefilled', (tester) async {
    await pumpDetail(
      tester,
      _todo(seq: 3, title: 'Write report', note: 'outline'),
    );
    await openMenu(tester);

    await tester.tap(find.text(l10n.todoMenuEdit));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('todoEditScreen')), findsOneWidget);
    final titleField = tester.widget<TextField>(
      find.byKey(const Key('todoTitleField')),
    );
    expect(titleField.controller!.text, 'Write report');
  });

  testWidgets('duplicate calls createTodo with title/priority/note', (
    tester,
  ) async {
    await pumpDetail(
      tester,
      _todo(
        seq: 3,
        title: 'Write report',
        priority: TodoPriority.p1,
        note: 'outline',
      ),
    );
    await openMenu(tester);

    await tester.tap(find.text(l10n.todoMenuDuplicate));
    await tester.pumpAndSettle();

    expect(repository.created, isNotNull);
    expect(repository.created!.title, 'Write report');
    expect(repository.created!.priority, TodoPriority.p1);
    expect(repository.created!.note, 'outline');

    // Lands on the new copy in edit mode, prefilled with the copied title.
    expect(find.byKey(const Key('todoEditScreen')), findsOneWidget);
    final titleField = tester.widget<TextField>(
      find.byKey(const Key('todoTitleField')),
    );
    expect(titleField.controller!.text, 'Write report');
  });

  testWidgets('delete asks for confirmation then deletes and pops', (
    tester,
  ) async {
    await pumpDetail(tester, _todo(seq: 3, title: 'Write report'));
    await openMenu(tester);

    await tester.tap(find.text(l10n.todoMenuDelete));
    await tester.pumpAndSettle();
    expect(find.text(l10n.todoDeleteConfirmTitle), findsOneWidget);

    // Confirm (the dialog's Delete button).
    await tester.tap(find.text(l10n.todoMenuDelete));
    await tester.pumpAndSettle();

    expect(repository.deletedId, 3);
    expect(find.byKey(const Key('todoDetailScreen')), findsNothing);
  });

  testWidgets('status chip opens the panel and updates the status', (
    tester,
  ) async {
    await pumpDetail(
      tester,
      _todo(seq: 3, title: 'Write report', status: TodoStatus.notStarted),
    );

    // Tap the status chip (shows the current status name).
    await tester.tap(find.text(l10n.todoStatusNotStarted));
    await tester.pumpAndSettle();
    expect(find.text(l10n.todoStatusSheetTitle), findsOneWidget);
    // The current status row carries the check mark.
    expect(find.byKey(const Key('todoStatusCurrent')), findsOneWidget);

    await tester.tap(find.text(l10n.todoStatusInProgress));
    await tester.pumpAndSettle();

    expect(repository.updatedId, 3);
    expect(repository.updatedStatus, TodoStatus.inProgress);
    expect(find.text(l10n.todoStatusSheetTitle), findsNothing);
  });

  testWidgets('detail shows the new title after an edit saves (live)', (
    tester,
  ) async {
    await pumpDetail(
      tester,
      _todo(seq: 3, title: 'Old title', note: 'old note'),
    );
    expect(find.text('#3  Old title'), findsOneWidget);

    await openMenu(tester);
    await tester.tap(find.text(l10n.todoMenuEdit));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('todoTitleField')),
      'New title',
    );
    await tester.tap(find.text(l10n.todoSaveButton));
    await tester.pumpAndSettle();

    // Back on the detail — it must reflect the edit, not the stale future.
    expect(find.text('#3  New title'), findsOneWidget);
    expect(find.text('#3  Old title'), findsNothing);
  });

  testWidgets('detail status chip reflects the new status after the panel', (
    tester,
  ) async {
    await pumpDetail(
      tester,
      _todo(seq: 3, title: 'Task', status: TodoStatus.notStarted),
    );
    expect(find.text(l10n.todoStatusNotStarted), findsOneWidget);

    await tester.tap(find.text(l10n.todoStatusNotStarted));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.todoStatusInProgress));
    await tester.pumpAndSettle();

    // The chip is live: it now shows the new status, the old one is gone.
    expect(find.text(l10n.todoStatusInProgress), findsOneWidget);
    expect(find.text(l10n.todoStatusNotStarted), findsNothing);
  });

  testWidgets('priority chip opens the panel and updates priority', (
    tester,
  ) async {
    await pumpDetail(
      tester,
      _todo(seq: 3, title: 'Task', priority: TodoPriority.p2),
    );

    await tester.tap(find.text('P2'));
    await tester.pumpAndSettle();
    expect(find.text(l10n.todoFormPriorityLabel), findsOneWidget);
    expect(find.byKey(const Key('todoPriorityCurrent')), findsOneWidget);

    await tester.tap(find.text('P0'));
    await tester.pumpAndSettle();

    expect(repository.updatedId, 3);
    expect(repository.updatedPriority, TodoPriority.p0);
    // The chip is live.
    expect(find.text('P0'), findsOneWidget);
  });

  testWidgets('due panel sets a relative date', (tester) async {
    await pumpDetail(tester, _todo(seq: 3, title: 'Task'));

    // No due yet -> chip shows "No date".
    await tester.tap(find.text(l10n.todoDueNone));
    await tester.pumpAndSettle();
    expect(find.text(l10n.todoFormDueLabel), findsOneWidget);

    await tester.tap(find.text(l10n.todoDueTomorrow));
    await tester.pumpAndSettle();

    final tomorrow = _today().add(const Duration(days: 1));
    expect(repository.updatedDueDate, tomorrow);
    expect(repository.updatedClearDueDate, isFalse);
  });

  testWidgets('pick a date on an overdue todo opens the picker (no crash)', (
    tester,
  ) async {
    await pumpDetail(
      tester,
      _todo(
        seq: 3,
        title: 'Task',
        // Overdue: earlier than today, so initialDate must be clamped.
        dueDate: _today().subtract(const Duration(days: 5)),
      ),
    );

    await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.todoDuePick));
    await tester.pumpAndSettle();

    // The date picker opened instead of throwing an initialDate assert.
    expect(find.byType(DatePickerDialog), findsOneWidget);
  });

  testWidgets('due panel can clear the due date', (tester) async {
    await pumpDetail(
      tester,
      _todo(
        seq: 3,
        title: 'Task',
        dueDate: _today().add(const Duration(days: 3)),
      ),
    );

    // Open via the dated chip (tomorrow/overdue/date text varies; use the ⌄).
    await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded).last);
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.todoDueClear));
    await tester.pumpAndSettle();

    expect(repository.updatedClearDueDate, isTrue);
  });

  testWidgets('update log renders entries in order with an auto tag', (
    tester,
  ) async {
    final base = DateTime(2026, 6, 1, 9);
    repository.logs = [
      TodoLog(
        id: 1,
        todoId: 3,
        text: 'started the outline',
        kind: TodoLogKind.manual,
        createdAt: base,
      ),
      TodoLog(
        id: 2,
        todoId: 3,
        text: 'did 1h',
        kind: TodoLogKind.auto,
        createdAt: base.add(const Duration(hours: 2)),
      ),
    ];
    await pumpDetail(tester, _todo(seq: 3, title: 'Write report'));

    expect(find.text('started the outline'), findsOneWidget);
    expect(find.text('did 1h'), findsOneWidget);
    // Only the auto entry carries the tag.
    expect(find.text(l10n.todoLogAutoTag), findsOneWidget);
  });

  testWidgets('empty update log shows the placeholder', (tester) async {
    await pumpDetail(tester, _todo(seq: 3, title: 'Write report'));

    expect(find.text(l10n.todoLogEmpty), findsOneWidget);
  });

  testWidgets('logging a note calls addLog(manual) and shows the entry', (
    tester,
  ) async {
    await pumpDetail(tester, _todo(seq: 3, title: 'Write report'));

    await tester.enterText(
      find.byKey(const Key('todoLogInput')),
      'made some progress',
    );
    await tester.tap(find.byKey(const Key('todoLogAddButton')));
    await tester.pumpAndSettle();

    expect(repository.addedLog?.text, 'made some progress');
    expect(repository.addedLog?.kind, TodoLogKind.manual);
    expect(find.text('made some progress'), findsOneWidget);
    expect(find.text(l10n.todoLogEmpty), findsNothing);
  });

  testWidgets('permanent items have no status chip to tap', (tester) async {
    await pumpDetail(
      tester,
      _todo(seq: 5, title: 'Game time', priority: TodoPriority.permanent),
    );

    // No status name shown at all (permanent has no status).
    expect(find.text(l10n.todoStatusNotStarted), findsNothing);
  });

  testWidgets('start jumps to chat and queues the composer todo', (
    tester,
  ) async {
    await pumpDetail(
      tester,
      _todo(seq: 3, title: 'Write report', status: TodoStatus.notStarted),
    );

    await tester.tap(find.text(l10n.todoStartBlock));
    await tester.pumpAndSettle();

    // Navigated to chat, and the chat probe sees the queued todo.
    expect(find.text('CHAT: #3 Write report'), findsOneWidget);
    // The todo's status was NOT changed by starting.
    expect(repository.updatedStatus, isNull);
    expect(repository.updatedId, isNull);
  });

  testWidgets('start nudges instead of navigating when a block is running', (
    tester,
  ) async {
    await pumpDetail(
      tester,
      _todo(seq: 3, title: 'Write report'),
      activePlan: _plan(),
    );

    await tester.tap(find.text(l10n.todoStartBlock));
    await tester.pumpAndSettle();

    expect(find.text(l10n.todoStartBusyHint), findsOneWidget);
    // Stayed on the detail (did not jump to chat).
    expect(find.byKey(const Key('todoDetailScreen')), findsOneWidget);
    expect(find.text('CHAT: #3 Write report'), findsNothing);
  });

  testWidgets('due chip text covers today / tomorrow / overdue / none', (
    tester,
  ) async {
    Future<void> pumpChip(DateTime? due) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Center(child: TodoDueChip(dueDate: due)),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    final today = _today();
    await pumpChip(today);
    expect(find.textContaining(l10n.todoDueToday), findsOneWidget);

    await pumpChip(today.add(const Duration(days: 1)));
    expect(find.textContaining(l10n.todoDueTomorrow), findsOneWidget);

    await pumpChip(today.subtract(const Duration(days: 3)));
    expect(find.textContaining(l10n.todoDueOverdue(3)), findsOneWidget);

    await pumpChip(null);
    expect(find.text(l10n.todoDueNone), findsOneWidget);
  });

  testWidgets('seeded permanent (#1) has no delete action', (tester) async {
    await pumpDetail(
      tester,
      _todo(seq: 1, title: 'Eat', priority: TodoPriority.permanent),
    );
    await openMenu(tester);

    expect(find.text(l10n.todoMenuEdit), findsOneWidget);
    expect(find.text(l10n.todoMenuDuplicate), findsOneWidget);
    expect(find.text(l10n.todoMenuDelete), findsNothing);
  });
}

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

Plan _plan() {
  final now = DateTime(2026, 6, 1, 9);
  return Plan(
    id: 1,
    todoId: null,
    title: 'Running',
    durationSec: 60 * 60,
    startAt: now,
    endAt: now.add(const Duration(hours: 1)),
    status: PlanStatus.running,
    note: null,
    locale: 'en',
    createdAt: now,
  );
}

/// Stands in for the chat tab; shows the queued composer todo so the start test
/// can prove both the navigation and the provider write.
class _ChatProbe extends ConsumerWidget {
  const _ChatProbe();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingComposerTodoProvider);
    final text = pending == null
        ? 'CHAT: none'
        : 'CHAT: #${pending.seq} ${pending.title}';
    return Scaffold(body: Center(child: Text(text)));
  }
}

class _FakeChatController extends ChatController {
  _FakeChatController(this._activePlan);

  final Plan? _activePlan;

  @override
  ChatState build() => ChatState(
    messages: const [],
    activePlan: _activePlan,
    pendingCheckIn: null,
  );
}

Todo _todo({
  required int seq,
  required String title,
  TodoStatus status = TodoStatus.notStarted,
  TodoPriority priority = TodoPriority.p2,
  DateTime? dueDate,
  String? note,
}) {
  final now = DateTime(2026, 6, 1);
  return Todo(
    id: seq,
    seq: seq,
    title: title,
    status: status,
    priority: priority,
    dueDate: dueDate,
    note: note,
    createdAt: now,
    updatedAt: now,
  );
}

class _DetailFakeRepository implements TodoRepository {
  // A live single-todo store: mutations re-emit so the detail (which derives
  // todoByIdProvider from watchTodos) refreshes — this is what guards the bug
  // PR #47/#48 had.
  final _controller = StreamController<List<Todo>>.broadcast();
  final _logController = StreamController<List<TodoLog>>.broadcast();
  Todo? todo;
  List<TodoLog> logs = const [];
  ({String text, TodoLogKind kind})? addedLog;
  ({String title, TodoPriority priority, DateTime? dueDate, String? note})?
  created;
  int? deletedId;
  int? updatedId;
  TodoStatus? updatedStatus;
  TodoPriority? updatedPriority;
  DateTime? updatedDueDate;
  bool? updatedClearDueDate;

  void dispose() {
    _controller.close();
    _logController.close();
  }

  void _emit() => _controller.add(todo == null ? const [] : [todo!]);

  @override
  Stream<List<Todo>> watchTodos() async* {
    yield todo == null ? const [] : [todo!];
    yield* _controller.stream;
  }

  @override
  Future<Todo?> getTodoById(int id) async => todo;

  @override
  Future<Todo> createTodo({
    required String title,
    TodoPriority priority = TodoPriority.p2,
    DateTime? dueDate,
    String? note,
  }) async {
    created = (title: title, priority: priority, dueDate: dueDate, note: note);
    return _todo(seq: 99, title: title, priority: priority, note: note);
  }

  @override
  Future<void> deleteTodo(int id) async {
    deletedId = id;
  }

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
    updatedStatus = status;
    updatedPriority = priority;
    updatedDueDate = dueDate;
    updatedClearDueDate = clearDueDate;
    final current = todo;
    if (current != null && current.id == id) {
      todo = current.copyWith(
        title: title ?? current.title,
        status: status ?? current.status,
        priority: priority ?? current.priority,
        dueDate: clearDueDate ? null : (dueDate ?? current.dueDate),
        note: clearNote ? null : (note ?? current.note),
      );
      _emit();
    }
  }

  @override
  Stream<List<TodoLog>> watchLogs(int todoId) async* {
    yield logs;
    yield* _logController.stream;
  }

  @override
  Future<void> addLog({
    required int todoId,
    required String text,
    required TodoLogKind kind,
  }) async {
    addedLog = (text: text, kind: kind);
    logs = [
      ...logs,
      TodoLog(
        id: logs.length + 1,
        todoId: todoId,
        text: text,
        kind: kind,
        createdAt: DateTime.now(),
      ),
    ];
    _logController.add(logs);
  }
}
