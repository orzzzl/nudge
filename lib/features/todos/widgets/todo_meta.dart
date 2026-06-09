import 'package:flutter/material.dart';

import '../../../app/cute_palette.dart';
import '../../../domain/todo.dart';
import '../../../l10n/generated/app_localizations.dart';

/// The relative due-date preview (`📅 Today` / `📅 2d overdue` / `📅 Jun 12`)
/// plus whether it's overdue, shared by the list row and the detail chip.
({String text, bool overdue}) todoDuePreview(
  BuildContext context,
  AppLocalizations l10n,
  DateTime dueDate,
) {
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
  final shortDate = MaterialLocalizations.of(context).formatShortDate(due);
  return (text: '📅 $shortDate', overdue: false);
}

/// Localized name for a todo status, shared by the list, detail, and panel.
String todoStatusName(AppLocalizations l10n, TodoStatus status) =>
    switch (status) {
      TodoStatus.notStarted => l10n.todoStatusNotStarted,
      TodoStatus.inProgress => l10n.todoStatusInProgress,
      TodoStatus.paused => l10n.todoStatusPaused,
      TodoStatus.done => l10n.todoStatusDone,
      TodoStatus.dropped => l10n.todoStatusDropped,
    };

/// The 5-state status dot (`.tstat`): a coloured circle with a glyph, shared by
/// the list row and the status panel. `notStarted` is an empty ring.
class TodoStatusDot extends StatelessWidget {
  const TodoStatusDot({required this.status, this.size = 25, super.key});

  final TodoStatus status;
  final double size;

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
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fill,
        gradient: gradient,
        shape: BoxShape.circle,
        border: Border.all(color: border, width: 2.5),
      ),
      child: glyph == null
          ? null
          : Icon(glyph, size: size * 0.56, color: glyphColor),
    );
  }
}

/// Priority flag (`.pflag`): coloured pill, shared by the list row and detail.
/// When [onTap] is set it's editable — shows a `⌄` and opens the priority panel.
class TodoPriorityChip extends StatelessWidget {
  const TodoPriorityChip({
    required this.priority,
    required this.label,
    this.onTap,
    super.key,
  });

  final TodoPriority priority;
  final String label;
  final VoidCallback? onTap;

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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: border, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: text,
              ),
            ),
            if (onTap != null)
              Icon(Icons.keyboard_arrow_down_rounded, size: 15, color: text),
          ],
        ),
      ),
    );
  }
}

/// Detail-page status chip: a status-coloured dot + the status name. When
/// [onTap] is set it's editable — shows a `⌄` and opens the status panel (29).
class TodoStatusChip extends StatelessWidget {
  const TodoStatusChip({
    required this.status,
    required this.label,
    this.onTap,
    super.key,
  });

  final TodoStatus status;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dot = switch (status) {
      TodoStatus.notStarted => CuteColors.todoStatusTodoBorder,
      TodoStatus.inProgress => CuteColors.matchaVivid,
      TodoStatus.paused => CuteColors.todoStatusPauseGlyph,
      TodoStatus.done => CuteColors.matchaVivid,
      TodoStatus.dropped => CuteColors.todoStatusDropGlyph,
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: CuteColors.white,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: CuteColors.borderNeutral, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: CuteColors.textBrown,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 3),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: CuteColors.textMuted,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Detail-page due chip: the [todoDuePreview] text (or "no date" when [dueDate]
/// is null), coral when overdue. When [onTap] is set it's editable (shows `⌄`).
class TodoDueChip extends StatelessWidget {
  const TodoDueChip({required this.dueDate, this.onTap, super.key});

  final DateTime? dueDate;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final date = dueDate;
    final due = date == null ? null : todoDuePreview(context, l10n, date);
    final text = due?.text ?? l10n.todoDueNone;
    final overdue = due?.overdue ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: CuteColors.white,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: overdue ? CuteColors.todoP0Border : CuteColors.borderNeutral,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: overdue
                    ? CuteColors.todoDueOver
                    : (date == null
                          ? CuteColors.textFaint
                          : CuteColors.textMuted),
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 15,
                color: CuteColors.textMuted,
              ),
          ],
        ),
      ),
    );
  }
}
