import 'package:flutter/material.dart';

import '../../../app/cute_palette.dart';
import '../../../app/widgets/candy.dart';
import '../../../domain/todo.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'todo_meta.dart';

/// One row in the todo list (mockup `.titem`): status dot, `#seq`, title +
/// preview, priority flag, chevron. Permanent rows hide the status dot and use a
/// lavender card; archived rows flatten and strike through (dimmed via colour,
/// never `opacity` — see task 26 notes).
class TodoListItem extends StatelessWidget {
  const TodoListItem({required this.todo, required this.onTap, super.key});

  final Todo todo;
  final VoidCallback onTap;

  bool get _isPermanent => todo.priority == TodoPriority.permanent;

  bool get _isArchived =>
      !_isPermanent &&
      (todo.status == TodoStatus.done || todo.status == TodoStatus.dropped);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final (bg, border, shadow) = switch ((_isPermanent, _isArchived)) {
      (true, _) => (
        CuteColors.todoPermBg,
        CuteColors.todoPermBorder,
        <BoxShadow>[],
      ),
      (_, true) => (
        CuteColors.todoArchBg,
        CuteColors.todoArchBorder,
        <BoxShadow>[],
      ),
      _ => (
        CuteColors.white,
        CuteColors.todoCardBorder,
        candyShadow(CuteColors.todoCardShadow, dy: 3),
      ),
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 2),
            boxShadow: shadow,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            children: [
              if (!_isPermanent) ...[
                _StatusDot(status: todo.status),
                const SizedBox(width: 11),
              ],
              Text(
                '#${todo.seq}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: CuteColors.textFaint2,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: _body(context, l10n, theme)),
              const SizedBox(width: 8),
              TodoPriorityChip(
                priority: todo.priority,
                label: _priorityLabel(l10n),
              ),
              const SizedBox(width: 6),
              const Text(
                '›',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: CuteColors.textFaint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    final title = Text(
      todo.title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: _isArchived ? CuteColors.textMuted : CuteColors.textBrown,
        decoration: _isArchived ? TextDecoration.lineThrough : null,
        decorationColor: CuteColors.textMuted,
      ),
    );

    // Permanent rows are just the title (no status / due preview).
    if (_isPermanent) {
      return title;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [title, const SizedBox(height: 3), _preview(context, l10n)],
    );
  }

  Widget _preview(BuildContext context, AppLocalizations l10n) {
    final dueDate = todo.dueDate;
    final due = dueDate == null ? null : todoDuePreview(context, l10n, dueDate);
    final statusName = _statusLabel(l10n);

    return Row(
      children: [
        if (due != null) ...[
          Text(
            due.text,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: due.overdue
                  ? CuteColors.todoDueOver
                  : CuteColors.todoDueText,
            ),
          ),
          const Text(
            ' · ',
            style: TextStyle(fontSize: 11.5, color: CuteColors.textMuted),
          ),
        ],
        Flexible(
          child: Text(
            statusName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: CuteColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }

  String _statusLabel(AppLocalizations l10n) => switch (todo.status) {
    TodoStatus.notStarted => l10n.todoStatusNotStarted,
    TodoStatus.inProgress => l10n.todoStatusInProgress,
    TodoStatus.paused => l10n.todoStatusPaused,
    TodoStatus.done => l10n.todoStatusDone,
    TodoStatus.dropped => l10n.todoStatusDropped,
  };

  String _priorityLabel(AppLocalizations l10n) => switch (todo.priority) {
    TodoPriority.p0 => 'P0',
    TodoPriority.p1 => 'P1',
    TodoPriority.p2 => 'P2',
    TodoPriority.permanent => l10n.todoPriorityPermanent,
  };
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.status});

  final TodoStatus status;

  @override
  Widget build(BuildContext context) {
    final (border, fill, gradient, glyph, glyphColor) = switch (status) {
      TodoStatus.notStarted => (
        CuteColors.todoStatusTodoBorder,
        CuteColors.todoStatusTodoBg,
        null,
        null,
        null,
      ),
      TodoStatus.inProgress => (
        CuteColors.matchaGradientBottom,
        null,
        CuteColors.matchaGradient,
        Icons.play_arrow_rounded,
        CuteColors.white,
      ),
      TodoStatus.paused => (
        CuteColors.todoStatusPauseBorder,
        CuteColors.todoStatusPauseBg,
        null,
        Icons.pause_rounded,
        CuteColors.todoStatusPauseGlyph,
      ),
      TodoStatus.done => (
        CuteColors.matchaGradientBottom,
        null,
        CuteColors.matchaGradient,
        Icons.check_rounded,
        CuteColors.white,
      ),
      TodoStatus.dropped => (
        CuteColors.todoStatusDropBorder,
        CuteColors.todoStatusDropBg,
        null,
        Icons.close_rounded,
        CuteColors.todoStatusDropGlyph,
      ),
    };

    return Container(
      width: 25,
      height: 25,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fill,
        gradient: gradient,
        shape: BoxShape.circle,
        border: Border.all(color: border, width: 2.5),
      ),
      child: glyph == null ? null : Icon(glyph, size: 14, color: glyphColor),
    );
  }
}
