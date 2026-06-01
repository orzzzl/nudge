import 'package:flutter_test/flutter_test.dart';
import 'package:nudge/domain/plan.dart';
import 'package:nudge/features/stats/stats_summary.dart';

void main() {
  test('aggregates planned total, completion, buckets, and ledger', () {
    final now = DateTime(2026, 6, 4, 12);
    final summary = aggregateStats([
      _plan(
        id: 1,
        title: 'Monday focus',
        startAt: DateTime(2026, 6, 1, 9),
        durationMin: 60,
        status: PlanStatus.done,
      ),
      _plan(
        id: 2,
        title: 'Tuesday focus',
        startAt: DateTime(2026, 6, 2, 10),
        durationMin: 30,
        status: PlanStatus.partial,
      ),
      _plan(
        id: 3,
        title: 'Later today',
        startAt: DateTime(2026, 6, 4, 8),
        durationMin: 45,
        status: PlanStatus.running,
      ),
      _plan(
        id: 4,
        title: 'Earlier today',
        startAt: DateTime(2026, 6, 4, 7),
        durationMin: 15,
        status: PlanStatus.missed,
      ),
      _plan(
        id: 5,
        title: 'Outside week',
        startAt: DateTime(2026, 5, 31, 9),
        durationMin: 120,
        status: PlanStatus.done,
      ),
    ], now);

    expect(summary.weekStart, DateTime(2026, 6));
    expect(summary.weekEnd, DateTime(2026, 6, 8));
    expect(summary.plannedMinutes, 150);
    expect(summary.plannedHours, 2.5);
    expect(summary.completionRate, 0.5);
    expect(summary.completionPercent, 50);
    expect(summary.streakDays, 1);
    expect(summary.dailyPlannedMinutes.map((day) => day.plannedMinutes), [
      60,
      30,
      0,
      60,
      0,
      0,
      0,
    ]);
    expect(summary.todaysPlans.map((plan) => plan.title), [
      'Earlier today',
      'Later today',
    ]);
  });

  test(
    'completion rate excludes running and abandoned without dividing by zero',
    () {
      final summary = aggregateStats([
        _plan(
          id: 1,
          startAt: DateTime(2026, 6, 1, 9),
          status: PlanStatus.running,
        ),
        _plan(
          id: 2,
          startAt: DateTime(2026, 6, 2, 9),
          status: PlanStatus.abandoned,
        ),
      ], DateTime(2026, 6, 4, 12));

      expect(summary.plannedMinutes, 120);
      expect(summary.completionRate, 0);
      expect(summary.completionPercent, 0);
    },
  );

  test('streak counts back from yesterday when today has no plan', () {
    final summary = aggregateStats([
      _plan(id: 1, startAt: DateTime(2026, 6, 1, 9)),
      _plan(id: 2, startAt: DateTime(2026, 6, 2, 9)),
      _plan(id: 3, startAt: DateTime(2026, 6, 3, 9)),
    ], DateTime(2026, 6, 4, 12));

    expect(summary.streakDays, 3);
  });

  test('streak counts today when today has a plan', () {
    final summary = aggregateStats([
      _plan(id: 1, startAt: DateTime(2026, 6, 2, 9)),
      _plan(id: 2, startAt: DateTime(2026, 6, 3, 9)),
      _plan(id: 3, startAt: DateTime(2026, 6, 4, 9)),
    ], DateTime(2026, 6, 4, 12));

    expect(summary.streakDays, 3);
  });

  test('streak carries across the Monday boundary', () {
    // now = Monday 2026-06-08; run is Fri+Sat+Sun (previous week) + Mon (today).
    // The old week-bounded streak would reset to 1 on Monday; unbounded = 4.
    final summary = aggregateStats([
      _plan(id: 1, startAt: DateTime(2026, 6, 5, 9)),
      _plan(id: 2, startAt: DateTime(2026, 6, 6, 9)),
      _plan(id: 3, startAt: DateTime(2026, 6, 7, 9)),
      _plan(id: 4, startAt: DateTime(2026, 6, 8, 9)),
    ], DateTime(2026, 6, 8, 12));

    expect(summary.streakDays, 4);
  });

  test('a gap does not connect two separate runs', () {
    // Mon/Tue active, Wed empty, then today (Fri). Only today's run counts.
    final summary = aggregateStats([
      _plan(id: 1, startAt: DateTime(2026, 6, 1, 9)),
      _plan(id: 2, startAt: DateTime(2026, 6, 2, 9)),
      _plan(id: 3, startAt: DateTime(2026, 6, 5, 9)),
    ], DateTime(2026, 6, 5, 12));

    expect(summary.streakDays, 1);
  });

  test('streak counts a run longer than two weeks', () {
    // 16 consecutive days ending today (crosses two Monday boundaries).
    final plans = [
      for (var i = 0; i < 16; i++)
        _plan(id: i + 1, startAt: DateTime(2026, 5, 20 + i, 9)),
    ];

    final summary = aggregateStats(plans, DateTime(2026, 6, 4, 12));

    expect(summary.streakDays, 16);
  });
}

Plan _plan({
  required int id,
  String title = 'Focus',
  required DateTime startAt,
  int durationMin = 60,
  PlanStatus status = PlanStatus.done,
}) {
  return Plan(
    id: id,
    title: title,
    durationMin: durationMin,
    startAt: startAt,
    endAt: startAt.add(Duration(minutes: durationMin)),
    status: status,
    note: null,
    locale: 'en',
    createdAt: startAt,
  );
}
