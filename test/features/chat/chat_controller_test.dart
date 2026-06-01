import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nudge/app/providers.dart';
import 'package:nudge/domain/plan.dart';
import 'package:nudge/domain/plan_repository.dart';
import 'package:nudge/domain/reminder_scheduler.dart';
import 'package:nudge/features/chat/chat_controller.dart';

void main() {
  test(
    'restore does not replace a plan created while restore is pending',
    () async {
      final restoredPlan = _plan(
        id: 1,
        title: 'Restored plan',
        startAt: DateTime(2026, 6, 1, 9),
      );
      final repository = _DelayedRestoreRepository(restoredPlan);
      final scheduler = _RecordingReminderScheduler();
      final container = ProviderContainer(
        overrides: [
          planRepositoryProvider.overrideWithValue(repository),
          reminderSchedulerProvider.overrideWithValue(scheduler),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(scheduler.dispose);

      expect(container.read(chatControllerProvider).activePlan, isNull);

      await container
          .read(chatControllerProvider.notifier)
          .createPlan(title: 'Fresh plan', durationMin: 30, locale: 'en');
      expect(
        container.read(chatControllerProvider).activePlan?.title,
        'Fresh plan',
      );

      repository.completeRestore();
      await Future<void>.delayed(Duration.zero);
      await container.pump();

      expect(
        container.read(chatControllerProvider).activePlan?.title,
        'Fresh plan',
      );
    },
  );

  test('schedules a check-in reminder after creating a plan', () async {
    final repository = _ControllerRepository();
    final scheduler = _RecordingReminderScheduler();
    final container = ProviderContainer(
      overrides: [
        planRepositoryProvider.overrideWithValue(repository),
        reminderSchedulerProvider.overrideWithValue(scheduler),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(scheduler.dispose);

    await container
        .read(chatControllerProvider.notifier)
        .createPlan(title: '  Focus block  ', durationMin: 45, locale: 'en');

    expect(scheduler.scheduled, hasLength(1));
    expect(scheduler.scheduled.single.planId, 10);
    expect(scheduler.scheduled.single.title, 'Focus block');
    expect(scheduler.scheduled.single.at, repository.createdPlan?.endAt);
  });

  test('cancels the reminder when checking in', () async {
    final repository = _ControllerRepository();
    final scheduler = _RecordingReminderScheduler();
    final container = ProviderContainer(
      overrides: [
        planRepositoryProvider.overrideWithValue(repository),
        reminderSchedulerProvider.overrideWithValue(scheduler),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(scheduler.dispose);

    final controller = container.read(chatControllerProvider.notifier);
    await controller.createPlan(
      title: 'Focus block',
      durationMin: 45,
      locale: 'en',
    );
    await controller.checkIn(PlanStatus.done);

    expect(repository.checkedInId, 10);
    expect(repository.checkedInStatus, PlanStatus.done);
    expect(scheduler.canceledPlanIds, [10]);
  });
}

class _DelayedRestoreRepository implements PlanRepository {
  _DelayedRestoreRepository(this._restoredPlan);

  final Plan _restoredPlan;
  final _restoreCompleter = Completer<Plan?>();
  Plan? _createdPlan;

  void completeRestore() {
    _restoreCompleter.complete(_restoredPlan);
  }

  @override
  Future<Plan> createPlan({
    required String title,
    required int durationMin,
    required DateTime startAt,
    required String locale,
  }) async {
    _createdPlan = _plan(
      id: 2,
      title: title,
      durationMin: durationMin,
      startAt: startAt,
      locale: locale,
    );

    return _createdPlan!;
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
    return _restoreCompleter.future;
  }

  @override
  Future<Plan?> getPlanById(int id) async {
    return id == _createdPlan?.id ? _createdPlan : null;
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
    throw UnimplementedError();
  }
}

class _ControllerRepository implements PlanRepository {
  Plan? createdPlan;
  int? checkedInId;
  PlanStatus? checkedInStatus;

  @override
  Future<Plan> createPlan({
    required String title,
    required int durationMin,
    required DateTime startAt,
    required String locale,
  }) async {
    createdPlan = _plan(
      id: 10,
      title: title,
      durationMin: durationMin,
      startAt: startAt,
      locale: locale,
    );

    return createdPlan!;
  }

  @override
  Future<void> checkIn({
    required int id,
    required PlanStatus status,
    String? note,
  }) async {
    checkedInId = id;
    checkedInStatus = status;
  }

  @override
  Future<Plan?> getActivePlan() async {
    return null;
  }

  @override
  Future<Plan?> getPlanById(int id) async {
    return id == createdPlan?.id ? createdPlan : null;
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
    throw UnimplementedError();
  }
}

class _RecordingReminderScheduler implements ReminderScheduler {
  final _tapController = StreamController<int>.broadcast();
  final scheduled = <_ScheduledReminder>[];
  final canceledPlanIds = <int>[];
  int? initialTappedPlanId;

  @override
  Stream<int> get onCheckInTapped => _tapController.stream;

  @override
  Future<void> cancel(int planId) async {
    canceledPlanIds.add(planId);
  }

  @override
  Future<void> scheduleCheckInReminder({
    required int planId,
    required String title,
    required DateTime at,
  }) async {
    scheduled.add(_ScheduledReminder(planId: planId, title: title, at: at));
  }

  @override
  Future<int?> takeInitialTappedPlanId() async {
    final planId = initialTappedPlanId;
    initialTappedPlanId = null;

    return planId;
  }

  Future<void> dispose() {
    return _tapController.close();
  }
}

class _ScheduledReminder {
  const _ScheduledReminder({
    required this.planId,
    required this.title,
    required this.at,
  });

  final int planId;
  final String title;
  final DateTime at;
}

Plan _plan({
  required int id,
  required String title,
  int durationMin = 60,
  required DateTime startAt,
  String locale = 'en',
}) {
  return Plan(
    id: id,
    title: title,
    durationMin: durationMin,
    startAt: startAt,
    endAt: startAt.add(Duration(minutes: durationMin)),
    status: PlanStatus.running,
    note: null,
    locale: locale,
    createdAt: startAt,
  );
}
