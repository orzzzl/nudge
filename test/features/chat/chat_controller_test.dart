import 'dart:async';

// ignore: depend_on_referenced_packages
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nudge/app/providers.dart';
import 'package:nudge/domain/app_settings.dart';
import 'package:nudge/domain/plan.dart';
import 'package:nudge/domain/plan_repository.dart';
import 'package:nudge/domain/reminder_scheduler.dart';
import 'package:nudge/features/chat/chat_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // createPlan now reads the settings (for 勿扰); the default SettingsController
  // loads SharedPreferences, so give the tests an initialized binding + empty
  // prefs (= 勿扰 off) unless a test overrides settingsControllerProvider.
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});

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
          .createPlan(title: 'Fresh plan', durationSec: 30 * 60, locale: 'en');
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
        .createPlan(
          title: '  Focus block  ',
          durationSec: 45 * 60,
          locale: 'en',
        );

    expect(scheduler.scheduled, hasLength(1));
    expect(scheduler.scheduled.single.planId, 10);
    expect(scheduler.scheduled.single.title, 'Focus block');
    expect(scheduler.scheduled.single.at, repository.createdPlan?.endAt);
    // 勿扰 defaults off -> the reminder is loud.
    expect(scheduler.scheduled.single.silent, isFalse);
  });

  test('schedules a SILENT reminder when 勿扰 (DND) is on', () async {
    final repository = _ControllerRepository();
    final scheduler = _RecordingReminderScheduler();
    final container = ProviderContainer(
      overrides: [
        planRepositoryProvider.overrideWithValue(repository),
        reminderSchedulerProvider.overrideWithValue(scheduler),
        settingsControllerProvider.overrideWith(_DndOnSettings.new),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(scheduler.dispose);

    await container
        .read(chatControllerProvider.notifier)
        .createPlan(title: 'Focus block', durationSec: 30 * 60, locale: 'en');

    expect(scheduler.scheduled.single.silent, isTrue);
  });

  test(
    'flipping 勿扰 mid-block re-schedules the active reminder to match',
    () async {
      final repository = _ControllerRepository();
      final scheduler = _RecordingReminderScheduler();
      final container = ProviderContainer(
        overrides: [
          planRepositoryProvider.overrideWithValue(repository),
          reminderSchedulerProvider.overrideWithValue(scheduler),
          settingsControllerProvider.overrideWith(_FlippableSettings.new),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(scheduler.dispose);

      final controller = container.read(chatControllerProvider.notifier);
      await controller.createPlan(
        title: 'Focus block',
        durationSec: 30 * 60,
        locale: 'en',
      );
      expect(scheduler.scheduled.single.silent, isFalse); // 勿扰 off at start

      // Turn 勿扰 ON before time-up -> the pending reminder is re-armed silent.
      await container.read(settingsControllerProvider.notifier).setDnd(true);
      await Future<void>.delayed(Duration.zero);
      expect(scheduler.scheduled.last.planId, 10);
      expect(scheduler.scheduled.last.silent, isTrue);

      // Turn it back OFF -> re-armed loud again (latest state wins).
      await container.read(settingsControllerProvider.notifier).setDnd(false);
      await Future<void>.delayed(Duration.zero);
      expect(scheduler.scheduled.last.silent, isFalse);
    },
  );

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
      durationSec: 45 * 60,
      locale: 'en',
    );
    await controller.checkIn(PlanStatus.done);

    expect(repository.checkedInId, 10);
    expect(repository.checkedInStatus, PlanStatus.done);
    expect(scheduler.canceledPlanIds, [10]);
  });

  test('auto-prompts when the active plan reaches its end time', () {
    fakeAsync((async) {
      final repository = _ControllerRepository();
      final scheduler = _RecordingReminderScheduler();
      final container = _container(repository, scheduler);

      unawaited(
        container
            .read(chatControllerProvider.notifier)
            .createPlan(
              title: 'Focus block',
              durationSec: 1 * 60,
              locale: 'en',
            ),
      );
      async.flushMicrotasks();

      expect(container.read(chatControllerProvider).pendingCheckIn, isNull);

      async.elapse(const Duration(minutes: 1));

      expect(container.read(chatControllerProvider).pendingCheckIn?.id, 10);

      container.dispose();
      unawaited(scheduler.dispose());
      async.flushMicrotasks();
    });
  });

  test(
    'prompts immediately when a restored active plan is already past end',
    () {
      fakeAsync((async) {
        final plan = _plan(
          id: 20,
          title: 'Expired plan',
          durationSec: 1 * 60,
          startAt: DateTime.now().subtract(const Duration(minutes: 5)),
        );
        final repository = _ControllerRepository(activePlan: plan);
        final scheduler = _RecordingReminderScheduler();
        final container = _container(repository, scheduler);

        container.read(chatControllerProvider);
        async.flushMicrotasks();

        final state = container.read(chatControllerProvider);
        expect(state.activePlan?.id, 20);
        expect(state.pendingCheckIn?.id, 20);

        container.dispose();
        unawaited(scheduler.dispose());
        async.flushMicrotasks();
      });
    },
  );

  test('prompts for a warm notification tap by loading the plan', () {
    fakeAsync((async) {
      final plan = _plan(id: 30, title: 'Tapped plan', startAt: DateTime.now());
      final repository = _ControllerRepository(plans: [plan]);
      final scheduler = _RecordingReminderScheduler();
      final container = _container(repository, scheduler);

      container.read(chatControllerProvider);
      scheduler.emitTap(30);
      async.flushMicrotasks();

      expect(repository.requestedPlanIds, [30]);
      expect(container.read(chatControllerProvider).pendingCheckIn, plan);

      container.dispose();
      unawaited(scheduler.dispose());
      async.flushMicrotasks();
    });
  });

  test('prompts for a cold-start notification tap by loading the plan', () {
    fakeAsync((async) {
      final plan = _plan(
        id: 40,
        title: 'Cold-start plan',
        startAt: DateTime.now(),
      );
      final repository = _ControllerRepository(plans: [plan]);
      final scheduler = _RecordingReminderScheduler(initialTappedPlanId: 40);
      final container = _container(repository, scheduler);

      container.read(chatControllerProvider);
      async.flushMicrotasks();

      expect(repository.requestedPlanIds, [40]);
      expect(container.read(chatControllerProvider).pendingCheckIn, plan);
      expect(scheduler.initialTappedPlanId, isNull);

      container.dispose();
      unawaited(scheduler.dispose());
      async.flushMicrotasks();
    });
  });

  test('does not prompt the same plan more than once', () {
    fakeAsync((async) {
      final plan = _plan(
        id: 50,
        title: 'Once-only plan',
        startAt: DateTime.now(),
      );
      final repository = _ControllerRepository(plans: [plan]);
      final scheduler = _RecordingReminderScheduler();
      final container = _container(repository, scheduler);
      final controller = container.read(chatControllerProvider.notifier);

      scheduler.emitTap(50);
      async.flushMicrotasks();
      expect(container.read(chatControllerProvider).pendingCheckIn?.id, 50);

      controller.consumePendingCheckIn();
      expect(container.read(chatControllerProvider).pendingCheckIn, isNull);

      scheduler.emitTap(50);
      async.flushMicrotasks();
      expect(repository.requestedPlanIds, [50, 50]);
      expect(container.read(chatControllerProvider).pendingCheckIn, isNull);

      container.dispose();
      unawaited(scheduler.dispose());
      async.flushMicrotasks();
    });
  });

  test('does not prompt when the tapped plan is already checked in', () {
    fakeAsync((async) {
      final plan = _plan(
        id: 60,
        title: 'Done plan',
        startAt: DateTime.now(),
        status: PlanStatus.done,
      );
      final repository = _ControllerRepository(plans: [plan]);
      final scheduler = _RecordingReminderScheduler();
      final container = _container(repository, scheduler);

      container.read(chatControllerProvider);
      scheduler.emitTap(60);
      async.flushMicrotasks();

      expect(repository.requestedPlanIds, [60]);
      expect(container.read(chatControllerProvider).pendingCheckIn, isNull);

      container.dispose();
      unawaited(scheduler.dispose());
      async.flushMicrotasks();
    });
  });

  // End-to-end of the time-up chain in one test, using the spy scheduler:
  // create -> schedule a reminder AT endAt -> time-up prompts -> check-in
  // records the outcome AND cancels the reminder. This is the flow the silent
  // notification escaped; the spy lets us assert the wiring without a device.
  test('full lifecycle: create -> schedule@endAt -> time-up -> check-in', () {
    fakeAsync((async) {
      final repository = _ControllerRepository();
      final scheduler = _RecordingReminderScheduler();
      final container = _container(repository, scheduler);
      final controller = container.read(chatControllerProvider.notifier);

      unawaited(
        controller.createPlan(
          title: 'Focus block',
          durationSec: 1 * 60,
          locale: 'en',
        ),
      );
      async.flushMicrotasks();

      // The reminder is scheduled for the plan's exact end time.
      expect(scheduler.scheduled.single.planId, 10);
      expect(scheduler.scheduled.single.at, repository.createdPlan?.endAt);

      // Time-up arrives -> the check-in is prompted.
      async.elapse(const Duration(minutes: 1));
      expect(container.read(chatControllerProvider).pendingCheckIn?.id, 10);

      // Checking in records the outcome and cancels the now-moot reminder.
      unawaited(controller.checkIn(PlanStatus.done));
      async.flushMicrotasks();

      expect(repository.checkedInStatus, PlanStatus.done);
      expect(scheduler.canceledPlanIds, [10]);
      final state = container.read(chatControllerProvider);
      expect(state.pendingCheckIn, isNull);
      expect(state.activePlan, isNull);

      container.dispose();
      unawaited(scheduler.dispose());
      async.flushMicrotasks();
    });
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
    required int durationSec,
    required DateTime startAt,
    required String locale,
  }) async {
    _createdPlan = _plan(
      id: 2,
      title: title,
      durationSec: durationSec,
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

ProviderContainer _container(
  PlanRepository repository,
  ReminderScheduler scheduler,
) {
  return ProviderContainer(
    overrides: [
      planRepositoryProvider.overrideWithValue(repository),
      reminderSchedulerProvider.overrideWithValue(scheduler),
    ],
  );
}

class _ControllerRepository implements PlanRepository {
  _ControllerRepository({this.activePlan, List<Plan> plans = const []}) {
    final activePlan = this.activePlan;
    if (activePlan?.id != null) {
      _plansById[activePlan!.id!] = activePlan;
    }
    for (final plan in plans) {
      final id = plan.id;
      if (id != null) {
        _plansById[id] = plan;
      }
    }
  }

  Plan? createdPlan;
  Plan? activePlan;
  int? checkedInId;
  PlanStatus? checkedInStatus;
  final requestedPlanIds = <int>[];
  final _plansById = <int, Plan>{};

  @override
  Future<Plan> createPlan({
    required String title,
    required int durationSec,
    required DateTime startAt,
    required String locale,
  }) async {
    createdPlan = _plan(
      id: 10,
      title: title,
      durationSec: durationSec,
      startAt: startAt,
      locale: locale,
    );
    activePlan = createdPlan;
    _plansById[createdPlan!.id!] = createdPlan!;

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
    final plan = _plansById[id];
    if (plan != null) {
      final updatedPlan = plan.copyWith(status: status, note: note);
      _plansById[id] = updatedPlan;
      if (activePlan?.id == id) {
        activePlan = updatedPlan;
      }
    }
  }

  @override
  Future<Plan?> getActivePlan() async {
    return activePlan;
  }

  @override
  Future<Plan?> getPlanById(int id) async {
    requestedPlanIds.add(id);
    return _plansById[id];
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
  _RecordingReminderScheduler({this.initialTappedPlanId});

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
    bool silent = false,
  }) async {
    scheduled.add(
      _ScheduledReminder(planId: planId, title: title, at: at, silent: silent),
    );
  }

  void emitTap(int planId) {
    _tapController.add(planId);
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

/// Settings stub with 勿扰 on, without touching SharedPreferences (build()
/// returns the state directly instead of loading it).
class _DndOnSettings extends SettingsController {
  @override
  AppSettings build() =>
      const AppSettings(dnd: true, localeOverride: LocaleOverride.system);
}

/// Settings stub starting with 勿扰 off and no async load, so a test can flip
/// `setDnd` deterministically (no SharedPreferences race resetting the state).
class _FlippableSettings extends SettingsController {
  @override
  AppSettings build() => AppSettings.defaults;
}

class _ScheduledReminder {
  const _ScheduledReminder({
    required this.planId,
    required this.title,
    required this.at,
    this.silent = false,
  });

  final int planId;
  final String title;
  final DateTime at;
  final bool silent;
}

Plan _plan({
  required int id,
  required String title,
  int durationSec = 60 * 60,
  required DateTime startAt,
  String locale = 'en',
  PlanStatus status = PlanStatus.running,
}) {
  return Plan(
    id: id,
    title: title,
    durationSec: durationSec,
    startAt: startAt,
    endAt: startAt.add(Duration(seconds: durationSec)),
    status: status,
    note: null,
    locale: locale,
    createdAt: startAt,
  );
}
