import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nudge/app/providers.dart';
import 'package:nudge/domain/plan.dart';
import 'package:nudge/domain/plan_repository.dart';
import 'package:nudge/features/stats/stats_providers.dart';

void main() {
  test('watches all history once and maps stream updates', () async {
    final repository = _FakePlanRepository();
    final container = ProviderContainer(
      overrides: [
        planRepositoryProvider.overrideWithValue(repository),
        statsNowProvider.overrideWithValue(DateTime(2026, 6, 4, 12)),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(repository.dispose);

    repository.emit([
      _plan(id: 1, startAt: DateTime(2026, 6, 1, 9), durationMin: 30),
    ]);

    final subscription = container.listen(
      statsSummaryProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    await container.pump();

    expect(repository.watchPlansInRangeCalls, 1);
    // Queries from a local sentinel before any plan exists up to this week's end
    // (unbounded streak); aggregateStats still slices the current week out.
    expect(repository.lastStart, DateTime(2000));
    expect(repository.lastEnd, DateTime(2026, 6, 8));
    expect(container.read(statsSummaryProvider).value?.plannedMinutes, 30);

    repository.emit([
      _plan(id: 1, startAt: DateTime(2026, 6, 1, 9), durationMin: 30),
      _plan(id: 2, startAt: DateTime(2026, 6, 4, 10), durationMin: 45),
    ]);
    await Future<void>.delayed(Duration.zero);
    await container.pump();

    expect(container.read(statsSummaryProvider).value?.plannedMinutes, 75);
  });
}

class _FakePlanRepository implements PlanRepository {
  final _controller = StreamController<List<Plan>>.broadcast();

  int watchPlansInRangeCalls = 0;
  DateTime? lastStart;
  DateTime? lastEnd;
  List<Plan>? _latestPlans;

  void emit(List<Plan> plans) {
    _latestPlans = plans;
    _controller.add(plans);
  }

  Future<void> dispose() {
    return _controller.close();
  }

  @override
  Future<Plan> createPlan({
    required String title,
    required int durationMin,
    required DateTime startAt,
    required String locale,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> checkIn({
    required int id,
    required PlanStatus status,
    String? note,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Plan?> getActivePlan() {
    throw UnimplementedError();
  }

  @override
  Future<Plan?> getPlanById(int id) {
    throw UnimplementedError();
  }

  @override
  Stream<List<Plan>> watchPlansForDay(DateTime day) {
    throw UnimplementedError();
  }

  @override
  Stream<List<Plan>> watchPlansInRange({
    required DateTime start,
    required DateTime end,
  }) {
    watchPlansInRangeCalls += 1;
    lastStart = start;
    lastEnd = end;

    return Stream.multi((controller) {
      final latestPlans = _latestPlans;
      if (latestPlans != null) {
        controller.add(latestPlans);
      }

      final subscription = _controller.stream.listen(
        controller.add,
        onError: controller.addError,
        onDone: controller.close,
      );
      controller.onCancel = subscription.cancel;
    });
  }
}

Plan _plan({
  required int id,
  required DateTime startAt,
  required int durationMin,
}) {
  return Plan(
    id: id,
    title: 'Focus',
    durationMin: durationMin,
    startAt: startAt,
    endAt: startAt.add(Duration(minutes: durationMin)),
    status: PlanStatus.running,
    note: null,
    locale: 'en',
    createdAt: startAt,
  );
}
