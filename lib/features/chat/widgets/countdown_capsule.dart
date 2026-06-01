import 'dart:async';

import 'package:flutter/material.dart';

import '../../../domain/plan.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Always-visible capsule for the running plan: title, a live mm:ss countdown,
/// and a check-in button. Automatic time-up prompting lives in the controller.
class CountdownCapsule extends StatefulWidget {
  const CountdownCapsule({
    required this.plan,
    required this.onCheckIn,
    super.key,
  });

  final Plan plan;
  final VoidCallback onCheckIn;

  @override
  State<CountdownCapsule> createState() => _CountdownCapsuleState();
}

class _CountdownCapsuleState extends State<CountdownCapsule> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Duration get _remaining => widget.plan.endAt.difference(DateTime.now());

  String _formatRemaining(Duration remaining) {
    final totalSeconds = remaining.inSeconds;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final remaining = _remaining;
    final isUp = remaining.isNegative || remaining == Duration.zero;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.plan.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isUp ? l10n.capsuleTimeUp : _formatRemaining(remaining),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonal(
              onPressed: widget.onCheckIn,
              child: Text(l10n.capsuleCheckIn),
            ),
          ],
        ),
      ),
    );
  }
}
