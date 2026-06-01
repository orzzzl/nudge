import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nudge/app/providers.dart';
import 'package:nudge/domain/plan.dart';
import 'package:nudge/domain/plan_repository.dart';
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
      final container = ProviderContainer(
        overrides: [planRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

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
