import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nudge/data/db/app_database.dart';
import 'package:nudge/domain/todo.dart' as domain;
import 'package:nudge/l10n/generated/app_localizations_en.dart';
import 'package:nudge/l10n/generated/app_localizations_zh.dart';

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

  test('seeds default permanent todos from English localizations', () async {
    final localizations = AppLocalizationsEn();

    final todos = await database.select(database.todos).get();

    expect(todos, hasLength(2));
    expect(todos.map((todo) => todo.seq), [1, 2]);
    expect(todos.map((todo) => todo.title), [
      localizations.todoSeedEatTitle,
      localizations.todoSeedSleepTitle,
    ]);
    expect(
      todos.map((todo) => todo.priority),
      everyElement(domain.TodoPriority.permanent.name),
    );
    expect(
      todos.map((todo) => todo.status),
      everyElement(domain.TodoStatus.notStarted.name),
    );
    expect(todos.map((todo) => todo.dueDate), everyElement(isNull));
  });

  test('can seed default permanent todos from Chinese localizations', () async {
    await database.close();
    final zhDatabase = AppDatabase.forTesting(
      NativeDatabase.memory(),
      seedLocaleName: 'zh',
    );
    database = zhDatabase;
    final localizations = AppLocalizationsZh();

    final todos = await zhDatabase.select(zhDatabase.todos).get();

    expect(todos.map((todo) => todo.title), [
      localizations.todoSeedEatTitle,
      localizations.todoSeedSleepTitle,
    ]);
  });

  test('enforces unique todo seq values', () async {
    await expectLater(
      database.into(database.todos).insert(_todoCompanion(seq: 1)),
      throwsA(isA<SqliteException>()),
    );
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

  test('gets the latest running plan and plan by id', () async {
    final earlyId = await plansDao.insertPlan(
      _planCompanion(
        title: 'Earlier plan',
        startAt: _day.add(const Duration(hours: 8)),
      ),
    );
    final latestId = await plansDao.insertPlan(
      _planCompanion(
        title: 'Latest running plan',
        startAt: _day.add(const Duration(hours: 11)),
      ),
    );
    final doneId = await plansDao.insertPlan(
      _planCompanion(
        title: 'Done plan',
        startAt: _day.add(const Duration(hours: 12)),
      ),
    );
    await plansDao.updateStatusAndNoteById(id: doneId, status: 'done');

    final activePlan = await plansDao.getActivePlan();
    final earlyPlan = await plansDao.getPlanById(earlyId);
    final missingPlan = await plansDao.getPlanById(999);

    expect(activePlan?.id, latestId);
    expect(activePlan?.title, 'Latest running plan');
    expect(earlyPlan?.id, earlyId);
    expect(earlyPlan?.title, 'Earlier plan');
    expect(missingPlan, isNull);
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
    durationSec: 60 * 60,
    startAt: resolvedStartAt,
    endAt: endAt ?? resolvedStartAt.add(const Duration(hours: 1)),
    createdAt: _day,
  );
}

TodosCompanion _todoCompanion({
  required int seq,
  String title = 'Duplicate todo',
}) {
  return TodosCompanion.insert(
    seq: seq,
    title: title,
    createdAt: _day,
    updatedAt: _day,
  );
}
