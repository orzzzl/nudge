import 'package:flutter/material.dart';

import '../../../domain/plan.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Show the check-in sheet for a plan. Resolves to the chosen [PlanStatus], or
/// null if the user dismissed it without picking.
Future<PlanStatus?> showCheckInSheet(
  BuildContext context, {
  required Plan plan,
}) {
  return showModalBottomSheet<PlanStatus>(
    context: context,
    showDragHandle: true,
    builder: (context) => _CheckInSheet(plan: plan),
  );
}

class _CheckInSheet extends StatelessWidget {
  const _CheckInSheet({required this.plan});

  final Plan plan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.checkInTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              l10n.checkInTaskLine(plan.title, plan.durationMin),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _Option(
                  emoji: '✅',
                  label: l10n.checkInDone,
                  onTap: () => Navigator.of(context).pop(PlanStatus.done),
                ),
                const SizedBox(width: 10),
                _Option(
                  emoji: '🍃',
                  label: l10n.checkInPartial,
                  onTap: () => Navigator.of(context).pop(PlanStatus.partial),
                ),
                const SizedBox(width: 10),
                _Option(
                  emoji: '😴',
                  label: l10n.checkInMissed,
                  onTap: () => Navigator.of(context).pop(PlanStatus.missed),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              l10n.checkInReassure,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 4),
            Text(label, style: theme.textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}
