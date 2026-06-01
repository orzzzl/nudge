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

  return StatsSummary(
    weekStart: weekStart,
    weekEnd: weekEnd,
    plannedMinutes: plannedMinutes,
    completionRate: checkedInCount == 0 ? 0 : completionScore / checkedInCount,
    streakDays: _calculateStreak(plannedByDay, today, weekStart),
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

int _calculateStreak(
  Map<DateTime, int> plannedByDay,
  DateTime today,
  DateTime weekStart,
) {
  var cursor = today;

  // A plan-free today does not break the streak until the day ends, so count
  // backward from yesterday in that case.
  if ((plannedByDay[today] ?? 0) == 0) {
    cursor = today.subtract(const Duration(days: 1));
  }

  var streak = 0;
  while (!cursor.isBefore(weekStart)) {
    if ((plannedByDay[cursor] ?? 0) == 0) {
      break;
    }
    streak += 1;
    cursor = cursor.subtract(const Duration(days: 1));
  }

  return streak;
}
