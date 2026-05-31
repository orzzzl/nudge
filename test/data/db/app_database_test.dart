import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nudge/data/db/app_database.dart';

void main() {
  late AppDatabase database;
  late PlansDao plansDao;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    plansDao = database.plansDao;
  });

  tearDown(() async {
    await database.close();
  });

  test('inserts a plan with forward-compatible text defaults', () async {
    final id = await plansDao.insertPlan(_planCompanion());

    final plans = await plansDao.watchPlansForDay(_day).first;

    expect(id, 1);
    expect(plans, hasLength(1));
    expect(plans.single.title, 'Write weekly report');
    expect(plans.single.status, 'running');
    expect(plans.single.locale, 'zh');
    expect(plans.single.note, isNull);
  });

  test('updates status and note by id', () async {
    final id = await plansDao.insertPlan(_planCompanion());

    final updatedRows = await plansDao.updateStatusAndNoteById(
      id: id,
      status: 'done',
      note: 'Finished',
    );
    final plans = await plansDao.watchPlansForDay(_day).first;

    expect(updatedRows, 1);
    expect(plans.single.status, 'done');
    expect(plans.single.note, 'Finished');
  });

  test('watch by day emits updated results reactively', () async {
    final expectation = expectLater(
      plansDao.watchPlansForDay(_day),
      emitsInOrder([
        predicate<List<Plan>>(
          (plans) => plans.length == 1 && plans.single.status == 'running',
          'one running plan',
        ),
        predicate<List<Plan>>(
          (plans) => plans.length == 1 && plans.single.status == 'partial',
          'one partial plan',
        ),
      ]),
    );

    final id = await plansDao.insertPlan(_planCompanion());
    await plansDao.updateStatusAndNoteById(
      id: id,
      status: 'partial',
      note: 'Half done',
    );

    await expectation;
  });

  test('watches plans in a date range', () async {
    await plansDao.insertPlan(_planCompanion());
    await plansDao.insertPlan(
      _planCompanion(
        title: 'Outside range',
        startAt: _day.add(const Duration(days: 2, hours: 9)),
        endAt: _day.add(const Duration(days: 2, hours: 10)),
      ),
    );

    final plans = await plansDao
        .watchPlansInRange(start: _day, end: _day.add(const Duration(days: 2)))
        .first;

    expect(plans, hasLength(1));
    expect(plans.single.title, 'Write weekly report');
  });
}

final _day = DateTime(2026, 5, 31);

PlansCompanion _planCompanion({
  String title = 'Write weekly report',
  DateTime? startAt,
  DateTime? endAt,
}) {
  final resolvedStartAt = startAt ?? _day.add(const Duration(hours: 9));

  return PlansCompanion.insert(
    title: title,
    durationMin: 60,
    startAt: resolvedStartAt,
    endAt: endAt ?? resolvedStartAt.add(const Duration(hours: 1)),
    createdAt: _day,
  );
}
