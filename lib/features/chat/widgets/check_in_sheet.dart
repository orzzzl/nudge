import 'package:flutter/material.dart';

import '../../../app/cute_palette.dart';
import '../../../app/widgets/candy.dart';
import '../../../domain/plan.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../pet/pet_mood.dart';
import '../../pet/pet_view.dart';

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
      // Scrollable so the taller cute card never overflows on short viewports
      // (small phones, landscape, the test surface).
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PetView(mood: PetMood.neutral, size: 56),
            const SizedBox(height: 10),
            Text(
              l10n.checkInTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.checkInTaskLine(plan.title, plan.durationMin),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: CuteColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _Option(
                  emoji: '✅',
                  label: l10n.checkInDone,
                  palette: _AnswerPalette.done,
                  onTap: () => Navigator.of(context).pop(PlanStatus.done),
                ),
                const SizedBox(width: 9),
                _Option(
                  emoji: '🍃',
                  label: l10n.checkInPartial,
                  palette: _AnswerPalette.partial,
                  onTap: () => Navigator.of(context).pop(PlanStatus.partial),
                ),
                const SizedBox(width: 9),
                _Option(
                  emoji: '😴',
                  label: l10n.checkInMissed,
                  palette: _AnswerPalette.missed,
                  onTap: () => Navigator.of(context).pop(PlanStatus.missed),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              l10n.checkInReassure,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: CuteColors.textFaint2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The done / partial / missed answer tiles each have their own semantic color
/// triad in the mockup; keep them as a private palette here rather than at the
/// call sites (they are single-use to this sheet).
class _AnswerPalette {
  const _AnswerPalette({
    required this.background,
    required this.border,
    required this.shadow,
    required this.foreground,
  });

  final Color background;
  final Color border;
  final Color shadow;
  final Color foreground;

  static const done = _AnswerPalette(
    background: CuteColors.mintConfirm,
    border: Color(0xFFBFE9CD),
    shadow: Color(0xFFD7F0E0),
    foreground: CuteColors.matchaVivid,
  );
  static const partial = _AnswerPalette(
    background: Color(0xFFFFF6E6),
    border: Color(0xFFFFE1A8),
    shadow: Color(0xFFFFEECB),
    foreground: Color(0xFFDD9B2E),
  );
  static const missed = _AnswerPalette(
    background: Color(0xFFFDF0EE),
    border: Color(0xFFF3D4CD),
    shadow: Color(0xFFF7DDD6),
    foreground: Color(0xFFCF8B7C),
  );
}

class _Option extends StatelessWidget {
  const _Option({
    required this.emoji,
    required this.label,
    required this.palette,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final _AnswerPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            decoration: BoxDecoration(
              color: palette.background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: palette.border, width: 2),
              boxShadow: candyShadow(palette.shadow, dy: 4),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 26)),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: palette.foreground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
