import 'plan.dart';

abstract class PlanRepository {
  Future<Plan> createPlan({
    required String title,
    required int durationSec,
    required DateTime startAt,
    required String locale,
  });

  Future<void> checkIn({
    required int id,
    required PlanStatus status,
    String? note,
  });

  Future<Plan?> getActivePlan();

  Future<Plan?> getPlanById(int id);

  Stream<List<Plan>> watchPlansForDay(DateTime day);

  Stream<List<Plan>> watchPlansInRange({
    required DateTime start,
    required DateTime end,
  });
}
