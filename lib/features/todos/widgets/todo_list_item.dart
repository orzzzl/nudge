import 'package:flutter/material.dart';

import '../../../app/cute_palette.dart';
import '../../../app/widgets/candy.dart';
import '../../../domain/todo.dart';
import '../../../l10n/generated/app_localizations.dart';

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
              _PriorityFlag(
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
    final due = _dueText(context, l10n);
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

  ({String text, bool overdue})? _dueText(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final dueDate = todo.dueDate;
    if (dueDate == null) {
      return null;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final days = due.difference(today).inDays;

    if (days < 0) {
      return (text: '📅 ${l10n.todoDueOverdue(-days)}', overdue: true);
    }
    if (days == 0) {
      return (text: '📅 ${l10n.todoDueToday}', overdue: false);
    }
    if (days == 1) {
      return (text: '📅 ${l10n.todoDueTomorrow}', overdue: false);
    }
    return (text: '📅 ${_shortDate(context, due)}', overdue: false);
  }

  String _shortDate(BuildContext context, DateTime date) {
    // Locale-aware short date without pulling in extra format strings.
    return MaterialLocalizations.of(context).formatShortDate(date);
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

class _PriorityFlag extends StatelessWidget {
  const _PriorityFlag({required this.priority, required this.label});

  final TodoPriority priority;
  final String label;

  @override
  Widget build(BuildContext context) {
    final (text, bg, border) = switch (priority) {
      TodoPriority.p0 => (
        CuteColors.todoP0Text,
        CuteColors.todoP0Bg,
        CuteColors.todoP0Border,
      ),
      TodoPriority.p1 => (
        CuteColors.todoP1Text,
        CuteColors.todoP1Bg,
        CuteColors.todoP1Border,
      ),
      TodoPriority.p2 => (
        CuteColors.todoP2Text,
        CuteColors.todoP2Bg,
        CuteColors.todoP2Border,
      ),
      TodoPriority.permanent => (
        CuteColors.todoPermText,
        CuteColors.todoPermFlagBg,
        CuteColors.todoPermFlagBorder,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: 2),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: text,
        ),
      ),
    );
  }
}
