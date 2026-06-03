import '../l10n/generated/app_localizations.dart';

/// Formats an internal per-second duration into a friendly, localized string.
///
/// Durations are stored in seconds, but users think in minutes/hours. Whole
/// hours read as "2 hr", sub-minute durations (debug-only short blocks) as
/// "30 sec", and everything else falls back to whole minutes ("90 min").
String formatPlanDuration(AppLocalizations l10n, int seconds) {
  if (seconds < 60) {
    return l10n.durationSecondsLabel(seconds);
  }
  if (seconds % 3600 == 0) {
    return l10n.durationHoursLabel(seconds ~/ 3600);
  }
  return l10n.durationChipLabel(seconds ~/ 60);
}
