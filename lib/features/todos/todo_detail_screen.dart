import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/cute_palette.dart';
import '../../app/providers.dart';
import '../../app/widgets/candy.dart';
import '../../domain/todo.dart';
import '../../l10n/generated/app_localizations.dart';
import '../chat/chat_controller.dart';
import '../chat/pending_composer_todo.dart';
import 'todos_controller.dart';
import 'widgets/todo_meta.dart';

/// Read-only todo detail (mockup ②): title + meta chips + note, a bottom
/// "start this block" action and a "⋯" menu (edit / duplicate / delete). The
/// status panel (29), update log (31), and start-jump (33) land in later tasks.
class TodoDetailScreen extends ConsumerWidget {
  const TodoDetailScreen({required this.todoId, super.key});

  final int todoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final todoAsync = ref.watch(todoByIdProvider(todoId));

    return Scaffold(
      key: const Key('todoDetailScreen'),
      backgroundColor: Colors.transparent,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: SafeArea(
        child: todoAsync.when(
          data: (todo) => todo == null
              ? Center(
                  child: Text(
                    l10n.todosLoadError,
                    style: const TextStyle(color: CuteColors.textMuted2),
                  ),
                )
              : _DetailContent(todo: todo),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: Text(
              l10n.todosLoadError,
              style: const TextStyle(color: CuteColors.textMuted2),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailContent extends ConsumerWidget {
  const _DetailContent({required this.todo});

  final Todo todo;

  bool get _isPermanent => todo.priority == TodoPriority.permanent;

  // The seeded everyday permanents (Eat #1 / Sleep #2) can't be deleted; seq is
  // never reused, so the first two permanents are always the seeds.
  bool get _isSeeded => _isPermanent && todo.seq <= 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            children: [
              Text(
                '#${todo.seq}  ${todo.title}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: CuteColors.textBrown,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (!_isPermanent)
                    TodoStatusChip(
                      status: todo.status,
                      label: todoStatusName(l10n, todo.status),
                      onTap: () => _showStatusPanel(context, ref),
                    ),
                  TodoPriorityChip(
                    priority: todo.priority,
                    label: _priorityLabel(l10n),
                    // Permanent <-> task conversion is done on the edit page.
                    onTap: _isPermanent
                        ? null
                        : () => _showPriorityPanel(context, ref),
                  ),
                  if (!_isPermanent)
                    TodoDueChip(
                      dueDate: todo.dueDate,
                      onTap: () => _showDuePanel(context, ref),
                    ),
                ],
              ),
              if (todo.note != null && todo.note!.trim().isNotEmpty) ...[
                const SizedBox(height: 22),
                Text(
                  l10n.todoDetailNoteLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: CuteColors.textMuted2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  todo.note!,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: CuteColors.textBrown,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              _UpdateLog(todoId: todo.id!),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          child: Row(
            children: [
              Expanded(
                child: CandyButton(
                  label: l10n.todoStartBlock,
                  onPressed: () => _start(context, ref),
                ),
              ),
              const SizedBox(width: 12),
              _MoreButton(
                tooltip: l10n.todoMoreActions,
                onTap: () => _showActions(context, ref),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Start a focus block from this todo: queue the composer chip and switch to
  // the chat tab. Never changes the todo's status. If a block is already
  // running the composer is hidden, so nudge instead of silently queuing.
  void _start(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    if (ref.read(chatControllerProvider).activePlan != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.todoStartBusyHint),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      return;
    }
    ref.read(pendingComposerTodoProvider.notifier).set((
      todoId: todo.id!,
      seq: todo.seq,
      title: todo.title,
    ));
    context.go('/chat');
  }

  void _showStatusPanel(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: CuteColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetTitle(l10n.todoStatusSheetTitle),
              for (final status in TodoStatus.values)
                ListTile(
                  leading: TodoStatusDot(status: status, size: 28),
                  title: Text(todoStatusName(l10n, status)),
                  trailing: status == todo.status
                      ? const Icon(
                          Icons.check_rounded,
                          key: Key('todoStatusCurrent'),
                          color: CuteColors.matcha,
                        )
                      : null,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    if (status != todo.status) {
                      ref
                          .read(todoRepositoryProvider)
                          .updateTodo(id: todo.id!, status: status);
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showPriorityPanel(BuildContext context, WidgetRef ref) {
    const options = [TodoPriority.p0, TodoPriority.p1, TodoPriority.p2];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: CuteColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetTitle(l10n.todoFormPriorityLabel),
              for (final priority in options)
                ListTile(
                  leading: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: _priorityColor(priority),
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(_priorityName(priority)),
                  trailing: priority == todo.priority
                      ? const Icon(
                          Icons.check_rounded,
                          key: Key('todoPriorityCurrent'),
                          color: CuteColors.matcha,
                        )
                      : null,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    if (priority != todo.priority) {
                      ref
                          .read(todoRepositoryProvider)
                          .updateTodo(id: todo.id!, priority: priority);
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showDuePanel(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    // The coming Saturday (today if it is Saturday).
    final weekend = today.add(
      Duration(days: (DateTime.saturday - today.weekday + 7) % 7),
    );

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: CuteColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext);

        void setDue(DateTime? date, {bool clear = false}) {
          Navigator.of(sheetContext).pop();
          ref
              .read(todoRepositoryProvider)
              .updateTodo(id: todo.id!, dueDate: date, clearDueDate: clear);
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetTitle(l10n.todoFormDueLabel),
              ListTile(
                title: Text(l10n.todoDueToday),
                onTap: () => setDue(today),
              ),
              ListTile(
                title: Text(l10n.todoDueTomorrow),
                onTap: () => setDue(tomorrow),
              ),
              ListTile(
                title: Text(l10n.todoDueWeekend),
                onTap: () => setDue(weekend),
              ),
              ListTile(
                leading: const Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: CuteColors.matcha,
                ),
                title: Text(l10n.todoDuePick),
                onTap: () async {
                  // Clamp to today: an overdue dueDate is before firstDate,
                  // which would trip showDatePicker's initialDate assert.
                  final due = todo.dueDate;
                  final initialDate = (due == null || due.isBefore(today))
                      ? today
                      : due;
                  final picked = await showDatePicker(
                    context: sheetContext,
                    initialDate: initialDate,
                    firstDate: today,
                    lastDate: DateTime(today.year + 5),
                  );
                  if (!sheetContext.mounted) {
                    return;
                  }
                  if (picked != null) {
                    setDue(DateTime(picked.year, picked.month, picked.day));
                  } else {
                    Navigator.of(sheetContext).pop();
                  }
                },
              ),
              if (todo.dueDate != null)
                ListTile(
                  leading: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: CuteColors.todoP0Text,
                  ),
                  title: Text(
                    l10n.todoDueClear,
                    style: const TextStyle(color: CuteColors.todoP0Text),
                  ),
                  onTap: () => setDue(null, clear: true),
                ),
            ],
          ),
        );
      },
    );
  }

  Color _priorityColor(TodoPriority priority) => switch (priority) {
    TodoPriority.p0 => CuteColors.todoP0Text,
    TodoPriority.p1 => CuteColors.todoP1Text,
    TodoPriority.p2 => CuteColors.todoP2Text,
    TodoPriority.permanent => CuteColors.todoPermText,
  };

  String _priorityName(TodoPriority priority) => switch (priority) {
    TodoPriority.p0 => 'P0',
    TodoPriority.p1 => 'P1',
    TodoPriority.p2 => 'P2',
    TodoPriority.permanent => 'permanent',
  };

  void _showActions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: CuteColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.edit_outlined,
                  color: CuteColors.matcha,
                ),
                title: Text(l10n.todoMenuEdit),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.push('/todos/${todo.id}/edit', extra: todo);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.copy_outlined,
                  color: CuteColors.matcha,
                ),
                title: Text(l10n.todoMenuDuplicate),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _duplicate(context, ref);
                },
              ),
              if (!_isSeeded)
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: CuteColors.todoP0Text,
                  ),
                  title: Text(
                    l10n.todoMenuDelete,
                    style: const TextStyle(color: CuteColors.todoP0Text),
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _confirmDelete(context, ref);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _duplicate(BuildContext context, WidgetRef ref) async {
    // Copy of the current title / priority / note — due, status and logs reset.
    final created = await ref
        .read(todoRepositoryProvider)
        .createTodo(
          title: todo.title,
          priority: todo.priority,
          note: todo.note,
        );
    // Open the copy in edit mode. pushReplacement so backing out of the editor
    // returns to the list, not this (the original's) detail page.
    if (context.mounted) {
      context.pushReplacement('/todos/${created.id}/edit', extra: created);
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.todoDeleteConfirmTitle),
        content: Text(l10n.todoDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.todoCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.todoMenuDelete,
              style: const TextStyle(color: CuteColors.todoP0Text),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }
    await ref.read(todoRepositoryProvider).deleteTodo(todo.id!);
    if (context.mounted) {
      context.pop();
    }
  }

  String _priorityLabel(AppLocalizations l10n) => switch (todo.priority) {
    TodoPriority.p0 => 'P0',
    TodoPriority.p1 => 'P1',
    TodoPriority.p2 => 'P2',
    TodoPriority.permanent => '♾️ ${l10n.todoPriorityPermanent}',
  };
}

/// The detail "Updates" timeline (chronological) + a manual "log a note" input.
/// Auto entries (check-in writeback, task 34) are marked with a peach dot + tag.
class _UpdateLog extends ConsumerStatefulWidget {
  const _UpdateLog({required this.todoId});

  final int todoId;

  @override
  ConsumerState<_UpdateLog> createState() => _UpdateLogState();
}

class _UpdateLogState extends ConsumerState<_UpdateLog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      return;
    }
    _controller.clear();
    await ref
        .read(todoRepositoryProvider)
        .addLog(todoId: widget.todoId, text: text, kind: TodoLogKind.manual);
  }

  String _time(BuildContext context, DateTime dt) {
    final now = DateTime.now();
    final ml = MaterialLocalizations.of(context);
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return ml.formatTimeOfDay(TimeOfDay.fromDateTime(dt));
    }
    return ml.formatShortDate(dt);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final logs =
        ref.watch(todoLogsProvider(widget.todoId)).asData?.value ??
        const <TodoLog>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.todoLogTitle,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: CuteColors.textMuted2,
          ),
        ),
        const SizedBox(height: 10),
        if (logs.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              l10n.todoLogEmpty,
              style: const TextStyle(fontSize: 13, color: CuteColors.textFaint),
            ),
          )
        else
          for (int i = 0; i < logs.length; i++)
            _LogRow(
              log: logs[i],
              isLast: i == logs.length - 1,
              time: _time(context, logs[i].createdAt),
              autoTag: l10n.todoLogAutoTag,
            ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                key: const Key('todoLogInput'),
                controller: _controller,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _add(),
                style: const TextStyle(
                  fontSize: 14,
                  color: CuteColors.textBrown,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: l10n.todoLogAddHint,
                  hintStyle: const TextStyle(color: CuteColors.textFaint2),
                  filled: true,
                  fillColor: CuteColors.fieldBg,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: CuteColors.borderPeach2,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: CuteColors.borderPeach2,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              key: const Key('todoLogAddButton'),
              tooltip: l10n.todoLogAddTooltip,
              onPressed: _add,
              icon: const Icon(Icons.add_rounded, color: CuteColors.matcha),
            ),
          ],
        ),
      ],
    );
  }
}

class _LogRow extends StatelessWidget {
  const _LogRow({
    required this.log,
    required this.isLast,
    required this.time,
    required this.autoTag,
  });

  final TodoLog log;
  final bool isLast;
  final String time;
  final String autoTag;

  @override
  Widget build(BuildContext context) {
    final isAuto = log.kind == TodoLogKind.auto;
    final dotColor = isAuto
        ? CuteColors.peachGradientBottom
        : CuteColors.matchaGradientBottom;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 3),
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: CuteColors.borderNeutral),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          log.text,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.35,
                            color: CuteColors.textBrown,
                          ),
                        ),
                      ),
                      if (isAuto) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: CuteColors.fieldBg,
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                              color: CuteColors.borderPeach,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            autoTag,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: CuteColors.peachCandyShadow,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 11,
                      color: CuteColors.textFaint,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetTitle extends StatelessWidget {
  const _SheetTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: CuteColors.textMuted2,
          ),
        ),
      ),
    );
  }
}

class _MoreButton extends StatelessWidget {
  const _MoreButton({required this.tooltip, required this.onTap});

  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: CuteColors.fieldBg2,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: const SizedBox(
            width: 52,
            height: 52,
            child: Icon(Icons.more_horiz, color: CuteColors.textMuted2),
          ),
        ),
      ),
    );
  }
}
