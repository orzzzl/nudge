import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nudge/data/db/app_database.dart' as db;
import 'package:nudge/data/repositories/plan_repository_impl.dart';
import 'package:nudge/domain/plan.dart';
import 'package:nudge/domain/plan_repository.dart';

void main() {
  late db.AppDatabase database;
  late PlanRepository repository;

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    repository = PlanRepositoryImpl(database.plansDao);
  });

  tearDown(() async {
    await database.close();
  });

  Future<Plan> createPlan({
    String title = 'Write weekly report',
    DateTime? startAt,
  }) {
    return repository.createPlan(
      title: title,
      durationMin: 60,
      startAt: startAt ?? _day.add(const Duration(hours: 9)),
      locale: 'en',
    );
  }

  test('createPlan returns the stored running plan', () async {
    final startAt = DateTime(2026, 5, 31, 9);

    final plan = await repository.createPlan(
      title: 'Write weekly report',
      durationMin: 90,
      startAt: startAt,
      locale: 'en',
    );

    expect(plan.id, isNotNull);
    expect(plan.title, 'Write weekly report');
    expect(plan.durationMin, 90);
    expect(plan.startAt, startAt);
    expect(plan.endAt, startAt.add(const Duration(minutes: 90)));
    expect(plan.status, PlanStatus.running);
    expect(plan.note, isNull);
    expect(plan.locale, 'en');
    expect(plan.createdAt, startAt);
  });

  test('checkIn updates status and note', () async {
    final plan = await createPlan();

    await repository.checkIn(
      id: plan.id!,
      status: PlanStatus.done,
      note: 'Finished',
    );
    final plans = await repository.watchPlansForDay(_day).first;

    expect(plans.single.status, PlanStatus.done);
    expect(plans.single.note, 'Finished');
  });

  test('watchPlansForDay emits domain plans reactively', () async {
    final expectation = expectLater(
      repository.watchPlansForDay(_day),
      emitsInOrder([
        predicate<List<Plan>>(
          (plans) =>
              plans.length == 1 && plans.single.status == PlanStatus.running,
          'one running domain plan',
        ),
        predicate<List<Plan>>(
          (plans) =>
              plans.length == 1 &&
              plans.single.status == PlanStatus.partial &&
              plans.single.note == 'Half done',
          'one partial domain plan',
        ),
      ]),
    );

    final plan = await createPlan();
    await repository.checkIn(
      id: plan.id!,
      status: PlanStatus.partial,
      note: 'Half done',
    );

    await expectation;
  });

  test('watchPlansInRange returns domain plans', () async {
    await createPlan(title: 'Inside range');
    await createPlan(
      title: 'Outside range',
      startAt: _day.add(const Duration(days: 2, hours: 9)),
    );

    final plans = await repository
        .watchPlansInRange(start: _day, end: _day.add(const Duration(days: 2)))
        .first;

    expect(plans, hasLength(1));
    expect(plans.single, isA<Plan>());
    expect(plans.single.title, 'Inside range');
  });

  test('getActivePlan returns the latest running plan or null', () async {
    final earlierPlan = await createPlan(
      title: 'Earlier running plan',
      startAt: _day.add(const Duration(hours: 8)),
    );
    final latestPlan = await createPlan(
      title: 'Latest running plan',
      startAt: _day.add(const Duration(hours: 10)),
    );
    final donePlan = await createPlan(
      title: 'Later checked-in plan',
      startAt: _day.add(const Duration(hours: 11)),
    );
    await repository.checkIn(id: donePlan.id!, status: PlanStatus.done);

    final activePlan = await repository.getActivePlan();

    expect(activePlan, latestPlan);

    await repository.checkIn(id: latestPlan.id!, status: PlanStatus.missed);
    await repository.checkIn(id: earlierPlan.id!, status: PlanStatus.partial);

    expect(await repository.getActivePlan(), isNull);
  });

  test('getPlanById returns a domain plan or null', () async {
    final plan = await createPlan(title: 'Find me');

    final foundPlan = await repository.getPlanById(plan.id!);

    expect(foundPlan, plan);
    expect(await repository.getPlanById(999), isNull);
  });

  test('PlanStatus values round-trip through DB text', () async {
    for (final (index, status) in PlanStatus.values.indexed) {
      final plan = await createPlan(
        title: status.name,
        startAt: _day.add(Duration(minutes: index)),
      );
      await repository.checkIn(id: plan.id!, status: status, note: status.name);
    }

    final domainPlans = await repository
        .watchPlansInRange(start: _day, end: _day.add(const Duration(days: 1)))
        .first;
    final dbRows = await database.plansDao
        .watchPlansInRange(start: _day, end: _day.add(const Duration(days: 1)))
        .first;

    expect(domainPlans.map((plan) => plan.status), PlanStatus.values);
    expect(
      dbRows.map((row) => row.status),
      PlanStatus.values.map((s) => s.name),
    );
  });

  test('Plan supports value equality and nullable copyWith fields', () async {
    final plan = await createPlan();

    expect(plan.copyWith(), plan);
    expect(plan.copyWith(note: 'A note').note, 'A note');
    expect(plan.copyWith(note: null).note, isNull);
    expect(plan.copyWith(id: null).id, isNull);
  });
}

final _day = DateTime(2026, 5, 31);
