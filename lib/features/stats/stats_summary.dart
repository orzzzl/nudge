import '../../domain/plan.dart';

class StatsSummary {
  const StatsSummary({
    required this.weekStart,
    required this.weekEnd,
    required this.plannedMinutes,
    required this.completionRate,
    required this.streakDays,
    required this.todaysPlans,
  });

  final DateTime weekStart;
  final DateTime weekEnd;
  final int plannedMinutes;
  final double completionRate;
  final int streakDays;
  final List<Plan> todaysPlans;

  double get plannedHours => plannedMinutes / 60;
  int get completionPercent => (completionRate * 100).round();
}

StatsSummary aggregateStats(List<Plan> plans, DateTime now) {
  final today = statsDayStart(now);
  final weekStart = statsWeekStart(now);
  final weekEnd = weekStart.add(const Duration(days: 7));
  final weekPlans = plans.where((plan) {
    return !plan.startAt.isBefore(weekStart) && plan.startAt.isBefore(weekEnd);
  }).toList()..sort((a, b) => a.startAt.compareTo(b.startAt));

  var plannedMinutes = 0;
  var checkedInCount = 0;
  var completionScore = 0.0;

  for (final plan in weekPlans) {
    plannedMinutes += plan.durationMin;

    switch (plan.status) {
      case PlanStatus.done:
        checkedInCount += 1;
        completionScore += 1;
      case PlanStatus.partial:
        checkedInCount += 1;
        completionScore += 0.5;
      // abandoned counts as a miss (a non-completion), same as missed.
      case PlanStatus.missed || PlanStatus.abandoned:
        checkedInCount += 1;
      case PlanStatus.running:
        break;
    }
  }

  final todaysPlans = weekPlans
      .where((plan) => statsDayStart(plan.startAt) == today)
      .toList();

  // Streak (rule B): a day counts only if it has >=1 plan that is NOT
  // missed/abandoned (i.e. at least one done/partial/running) — a fully
  // missed/abandoned day no longer extends it. Built from ALL plans so it
  // carries across week/month boundaries. All local time.
  final activeDays = <DateTime>{
    for (final plan in plans)
      if (plan.status != PlanStatus.missed &&
          plan.status != PlanStatus.abandoned)
        statsDayStart(plan.startAt),
  };

  return StatsSummary(
    weekStart: weekStart,
    weekEnd: weekEnd,
    plannedMinutes: plannedMinutes,
    completionRate: checkedInCount == 0 ? 0 : completionScore / checkedInCount,
    streakDays: _calculateStreak(activeDays, today),
    todaysPlans: List.unmodifiable(todaysPlans),
  );
}

DateTime statsWeekStart(DateTime value) {
  final day = statsDayStart(value);
  return day.subtract(Duration(days: day.weekday - DateTime.monday));
}

DateTime statsDayStart(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

int _calculateStreak(Set<DateTime> activeDays, DateTime today) {
  // A plan-free today does not break the streak until the day ends, so count
  // backward from yesterday in that case.
  var cursor = activeDays.contains(today) ? today : _previousDay(today);

  var streak = 0;
  while (activeDays.contains(cursor)) {
    streak += 1;
    cursor = _previousDay(cursor);
  }

  return streak;
}

// The previous calendar day at local midnight. Built from y/m/(d-1) rather than
// subtract(Duration(days: 1)) so it stays exactly on local midnight across DST
// transitions (24h arithmetic would land an hour off and miss an activeDays key).
DateTime _previousDay(DateTime day) {
  return DateTime(day.year, day.month, day.day - 1);
}

// ===========================================================================
// 乖乖图 v2 — time-series for the planned-hours + completion-rate line charts.
// ===========================================================================

/// The selectable time windows for the stats line charts (stock-style).
enum StatsRange { week, month, ytd, fiveYears, all }

/// One plotted point: a bucket's planned hours and completion rate.
class StatsPoint {
  const StatsPoint({
    required this.start,
    required this.plannedHours,
    required this.completionRate,
  });

  /// Local start of the bucket (day / week-Monday / month-1st).
  final DateTime start;

  /// Total planned hours in the bucket (>= 0, decimals).
  final double plannedHours;

  /// (done + partial) / (done + partial + missed + abandoned), with partial
  /// counting as complete and abandoned as a miss. A bucket with no countable
  /// plan is 0 (charts fill empty buckets with zero, not gaps).
  final double completionRate;
}

enum _Bucket { day, week, month }

/// Builds the continuous bucketed series for [range] from ALL [plans], in local
/// time. Buckets with no plans are still present and zero-filled (planned hours
/// = 0, completion = 0) so the x-axis is continuous.
List<StatsPoint> buildStatsSeries(
  List<Plan> plans,
  StatsRange range,
  DateTime now,
) {
  final today = statsDayStart(now);
  // dataStart = the inclusion lower bound (e.g. Jan 1 for YTD); firstBucket =
  // the aligned start of the bucket containing it (e.g. that week's Monday,
  // which may be in late December). Filtering by dataStart keeps prior-period
  // days out of the first bucket while the x-axis still aligns to bucket edges.
  final (dataStart, bucket) = _rangeStart(range, today, plans);
  final firstBucket = _bucketStart(dataStart, bucket);

  // Accumulators keyed by bucket start.
  final plannedMin = <DateTime, int>{};
  final done = <DateTime, int>{};
  final partial = <DateTime, int>{};
  final misses = <DateTime, int>{}; // missed + abandoned

  for (final plan in plans) {
    final day = statsDayStart(plan.startAt);
    if (day.isBefore(dataStart) || day.isAfter(today)) {
      continue;
    }
    final key = _bucketStart(day, bucket);
    plannedMin[key] = (plannedMin[key] ?? 0) + plan.durationMin;
    switch (plan.status) {
      case PlanStatus.done:
        done[key] = (done[key] ?? 0) + 1;
      case PlanStatus.partial:
        partial[key] = (partial[key] ?? 0) + 1;
      case PlanStatus.missed || PlanStatus.abandoned:
        misses[key] = (misses[key] ?? 0) + 1;
      case PlanStatus.running:
        break;
    }
  }

  final points = <StatsPoint>[];
  for (
    var cursor = firstBucket;
    !cursor.isAfter(today);
    cursor = _nextBucket(cursor, bucket)
  ) {
    final d = done[cursor] ?? 0;
    final p = partial[cursor] ?? 0;
    final m = misses[cursor] ?? 0;
    final countable = d + p + m;
    points.add(
      StatsPoint(
        start: cursor,
        plannedHours: (plannedMin[cursor] ?? 0) / 60,
        completionRate: countable == 0 ? 0 : (d + p) / countable,
      ),
    );
  }

  return List.unmodifiable(points);
}

/// The data-inclusion lower bound + bucket granularity for a range, in local
/// calendar time. (The first *bucket* is derived from this via _bucketStart;
/// plans before this bound are excluded even if they share the first bucket.)
(DateTime, _Bucket) _rangeStart(
  StatsRange range,
  DateTime today,
  List<Plan> plans,
) {
  switch (range) {
    case StatsRange.week:
      return (_addDays(today, -6), _Bucket.day); // 7 daily points
    case StatsRange.month:
      return (_addDays(today, -29), _Bucket.day); // 30 daily points
    case StatsRange.ytd:
      // Jan 1 of this year — NOT the containing week's Monday, so last year's
      // tail days don't leak into the first weekly bucket.
      return (DateTime(today.year), _Bucket.week);
    case StatsRange.fiveYears:
      // 60 monthly buckets ending this month → start 59 months back.
      return (DateTime(today.year, today.month - 59), _Bucket.month);
    case StatsRange.all:
      if (plans.isEmpty) {
        return (DateTime(today.year, today.month), _Bucket.month);
      }
      final earliest = plans
          .map((p) => statsDayStart(p.startAt))
          .reduce((a, b) => a.isBefore(b) ? a : b);
      return (DateTime(earliest.year, earliest.month), _Bucket.month);
  }
}

DateTime _bucketStart(DateTime day, _Bucket bucket) {
  return switch (bucket) {
    _Bucket.day => day,
    _Bucket.week => statsWeekStart(day),
    _Bucket.month => DateTime(day.year, day.month),
  };
}

DateTime _nextBucket(DateTime cursor, _Bucket bucket) {
  return switch (bucket) {
    _Bucket.day => _addDays(cursor, 1),
    _Bucket.week => _addDays(cursor, 7),
    _Bucket.month => DateTime(cursor.year, cursor.month + 1),
  };
}

DateTime _addDays(DateTime day, int delta) {
  return DateTime(day.year, day.month, day.day + delta);
}
