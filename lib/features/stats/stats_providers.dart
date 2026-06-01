import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import 'stats_summary.dart';

final statsNowProvider = Provider<DateTime>((ref) {
  return DateTime.now();
});

final statsSummaryProvider = StreamProvider<StatsSummary>((ref) {
  final now = ref.watch(statsNowProvider);
  final weekStart = statsWeekStart(now);
  final weekEnd = weekStart.add(const Duration(days: 7));
  final repository = ref.watch(planRepositoryProvider);

  return repository
      .watchPlansInRange(start: weekStart, end: weekEnd)
      .map((plans) => aggregateStats(plans, now));
});
