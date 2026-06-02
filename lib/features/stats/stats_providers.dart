import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/plan.dart';
import 'stats_summary.dart';

final statsNowProvider = Provider<DateTime>((ref) {
  return DateTime.now();
});

/// All plans (history → this week's end), in local time. The stats screen
/// derives both the hero/ledger summary (aggregateStats) and the line-chart
/// series (buildStatsSeries) from this single stream, so changing the chart
/// range needs no re-query. DateTime(2000) is a local sentinel before any plan
/// can exist — no UTC anywhere.
final statsPlansProvider = StreamProvider<List<Plan>>((ref) {
  final now = ref.watch(statsNowProvider);
  final weekEnd = statsWeekStart(now).add(const Duration(days: 7));
  return ref
      .watch(planRepositoryProvider)
      .watchPlansInRange(start: DateTime(2000), end: weekEnd);
});

/// Hero/ledger/streak summary derived from the single plan stream. The mascot
/// mood ([petMoodProvider]) watches this; the stats screen derives its own
/// summary + chart series directly from [statsPlansProvider].
final statsSummaryProvider = Provider<AsyncValue<StatsSummary>>((ref) {
  final now = ref.watch(statsNowProvider);
  return ref
      .watch(statsPlansProvider)
      .whenData((plans) => aggregateStats(plans, now));
});
