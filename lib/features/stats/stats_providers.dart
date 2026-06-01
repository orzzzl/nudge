import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import 'stats_summary.dart';

final statsNowProvider = Provider<DateTime>((ref) {
  return DateTime.now();
});

final statsSummaryProvider = StreamProvider<StatsSummary>((ref) {
  final now = ref.watch(statsNowProvider);
  final weekEnd = statsWeekStart(now).add(const Duration(days: 7));
  final repository = ref.watch(planRepositoryProvider);

  // The streak is unbounded, so query from before any plan can exist up to this
  // week's end; aggregateStats slices the current week back out for the chart /
  // ledger. DateTime(2000) is a LOCAL sentinel — all date math stays local.
  return repository
      .watchPlansInRange(start: DateTime(2000), end: weekEnd)
      .map((plans) => aggregateStats(plans, now));
});
