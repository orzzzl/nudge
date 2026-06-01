import '../../domain/plan.dart';

class StatsSummary {
  const StatsSummary({
    required this.weekStart,
    required this.weekEnd,
    required this.plannedMinutes,
    required this.completionRate,
    required this.streakDays,
    required this.dailyPlannedMinutes,
    required this.todaysPlans,
  });

  final DateTime weekStart;
  final DateTime weekEnd;
  final int plannedMinutes;
  final double completionRate;
  final int streakDays;
  final List<DailyPlannedMinutes> dailyPlannedMinutes;
  final List<Plan> todaysPlans;

  double get plannedHours => plannedMinutes / 60;
  int get completionPercent => (completionRate * 100).round();
  int get maxDailyPlannedMinutes {
    return dailyPlannedMinutes.fold<int>(
      0,
      (max, day) => day.plannedMinutes > max ? day.plannedMinutes : max,
    );
  }
}

class DailyPlannedMinutes {
  const DailyPlannedMinutes({required this.day, required this.plannedMinutes});

  final DateTime day;
  final int plannedMinutes;
}

StatsSummary aggregateStats(List<Plan> plans, DateTime now) {
  final today = statsDayStart(now);
  final weekStart = statsWeekStart(now);
  final weekEnd = weekStart.add(const Duration(days: 7));
  final weekPlans = plans.where((plan) {
    return !plan.startAt.isBefore(weekStart) && plan.startAt.isBefore(weekEnd);
  }).toList()..sort((a, b) => a.startAt.compareTo(b.startAt));

  final plannedByDay = <DateTime, int>{
    for (var index = 0; index < 7; index++)
      weekStart.add(Duration(days: index)): 0,
  };

  var plannedMinutes = 0;
  var checkedInCount = 0;
  var completionScore = 0.0;

  for (final plan in weekPlans) {
    final day = statsDayStart(plan.startAt);
    plannedMinutes += plan.durationMin;
    plannedByDay[day] = (plannedByDay[day] ?? 0) + plan.durationMin;

    switch (plan.status) {
      case PlanStatus.done:
        checkedInCount += 1;
        completionScore += 1;
      case PlanStatus.partial:
        checkedInCount += 1;
        completionScore += 0.5;
      case PlanStatus.missed:
        checkedInCount += 1;
      case PlanStatus.running || PlanStatus.abandoned:
        break;
    }
  }

  final dailyPlannedMinutes = [
    for (var index = 0; index < 7; index++)
      DailyPlannedMinutes(
        day: weekStart.add(Duration(days: index)),
        plannedMinutes: plannedByDay[weekStart.add(Duration(days: index))] ?? 0,
      ),
  ];

  final todaysPlans = weekPlans
      .where((plan) => statsDayStart(plan.startAt) == today)
      .toList();

  // The streak is unbounded: any local calendar day with >=1 planned block (any
  // outcome) counts. Built from ALL plans, not just this week, so it carries
  // across week/month boundaries.
  final activeDays = <DateTime>{
    for (final plan in plans) statsDayStart(plan.startAt),
  };

  return StatsSummary(
    weekStart: weekStart,
    weekEnd: weekEnd,
    plannedMinutes: plannedMinutes,
    completionRate: checkedInCount == 0 ? 0 : completionScore / checkedInCount,
    streakDays: _calculateStreak(activeDays, today),
    dailyPlannedMinutes: List.unmodifiable(dailyPlannedMinutes),
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
