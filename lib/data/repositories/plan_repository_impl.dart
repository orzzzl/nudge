import 'package:drift/drift.dart' as drift;

import '../../domain/plan.dart';
import '../../domain/plan_repository.dart';
import '../db/app_database.dart' as db;

class PlanRepositoryImpl implements PlanRepository {
  const PlanRepositoryImpl(this._plansDao);

  final db.PlansDao _plansDao;

  @override
  Future<Plan> createPlan({
    required String title,
    required int durationSec,
    required DateTime startAt,
    required String locale,
  }) async {
    final endAt = startAt.add(Duration(seconds: durationSec));
    final id = await _plansDao.insertPlan(
      db.PlansCompanion.insert(
        title: title,
        durationSec: durationSec,
        startAt: startAt,
        endAt: endAt,
        status: drift.Value(PlanStatus.running.name),
        note: const drift.Value<String?>(null),
        locale: drift.Value(locale),
        createdAt: startAt,
      ),
    );

    return Plan(
      id: id,
      todoId: null,
      title: title,
      durationSec: durationSec,
      startAt: startAt,
      endAt: endAt,
      status: PlanStatus.running,
      note: null,
      locale: locale,
      createdAt: startAt,
    );
  }

  @override
  Future<void> checkIn({
    required int id,
    required PlanStatus status,
    String? note,
  }) async {
    await _plansDao.updateStatusAndNoteById(
      id: id,
      status: status.name,
      note: note,
    );
  }

  @override
  Future<Plan?> getActivePlan() async {
    final row = await _plansDao.getActivePlan();

    return row == null ? null : _mapRow(row);
  }

  @override
  Future<Plan?> getPlanById(int id) async {
    final row = await _plansDao.getPlanById(id);

    return row == null ? null : _mapRow(row);
  }

  @override
  Stream<List<Plan>> watchPlansForDay(DateTime day) {
    return _plansDao.watchPlansForDay(day).map(_mapRows);
  }

  @override
  Stream<List<Plan>> watchPlansInRange({
    required DateTime start,
    required DateTime end,
  }) {
    return _plansDao.watchPlansInRange(start: start, end: end).map(_mapRows);
  }

  List<Plan> _mapRows(List<db.Plan> rows) {
    return rows.map(_mapRow).toList(growable: false);
  }

  Plan _mapRow(db.Plan row) {
    return Plan(
      id: row.id,
      todoId: row.todoId,
      title: row.title,
      durationSec: row.durationSec,
      startAt: row.startAt,
      endAt: row.endAt,
      status: _statusFromText(row.status),
      note: row.note,
      locale: row.locale,
      createdAt: row.createdAt,
    );
  }

  PlanStatus _statusFromText(String status) {
    try {
      return PlanStatus.values.byName(status);
    } on ArgumentError catch (_) {
      throw StateError('Unknown plan status: $status');
    }
  }
}
