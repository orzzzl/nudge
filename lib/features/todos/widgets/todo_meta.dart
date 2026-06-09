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

/// Priority flag (`.pflag`): coloured pill, shared by the list row and detail.
class TodoPriorityChip extends StatelessWidget {
  const TodoPriorityChip({
    required this.priority,
    required this.label,
    super.key,
  });

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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: border, width: 2),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: text,
        ),
      ),
    );
  }
}

/// Detail-page status chip: a status-coloured dot + the status name.
class TodoStatusChip extends StatelessWidget {
  const TodoStatusChip({required this.status, required this.label, super.key});

  final TodoStatus status;
  final String label;

  @override
  Widget build(BuildContext context) {
    final dot = switch (status) {
      TodoStatus.notStarted => CuteColors.todoStatusTodoBorder,
      TodoStatus.inProgress => CuteColors.matchaVivid,
      TodoStatus.paused => CuteColors.todoStatusPauseGlyph,
      TodoStatus.done => CuteColors.matchaVivid,
      TodoStatus.dropped => CuteColors.todoStatusDropGlyph,
    };

    return Container(
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
        ],
      ),
    );
  }
}

/// Detail-page due chip: the [todoDuePreview] text, coral when overdue.
class TodoDueChip extends StatelessWidget {
  const TodoDueChip({required this.dueDate, super.key});

  final DateTime dueDate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final due = todoDuePreview(context, l10n, dueDate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: CuteColors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: due.overdue
              ? CuteColors.todoP0Border
              : CuteColors.borderNeutral,
          width: 2,
        ),
      ),
      child: Text(
        due.text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: due.overdue ? CuteColors.todoDueOver : CuteColors.textMuted,
        ),
      ),
    );
  }
}
