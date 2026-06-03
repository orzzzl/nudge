import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class Plans extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  IntColumn get durationSec => integer()();
  DateTimeColumn get startAt => dateTime()();
  DateTimeColumn get endAt => dateTime()();
  TextColumn get status => text().withDefault(const Constant('running'))();
  TextColumn get note => text().nullable()();
  TextColumn get locale => text().withDefault(const Constant('zh'))();
  DateTimeColumn get createdAt => dateTime()();
}

class PetConfigs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get schemaVer => integer().withDefault(const Constant(1))();
  TextColumn get configJson => text()();
  DateTimeColumn get updatedAt => dateTime()();
}

@DriftDatabase(tables: [Plans, PetConfigs], daos: [PlansDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) => migrator.createAll(),
      onUpgrade: (migrator, from, to) async {
        // v2: durations are stored in seconds instead of minutes. Recreate the
        // table so the old `duration_min` column is dropped, backfilling the new
        // `duration_sec` from it (×60). CustomExpression references the old
        // physical column, which no longer exists in the Dart schema.
        if (from < 2) {
          // TableMigration is the documented drift recipe for dropping/renaming
          // a column via table recreation; the @experimental tag is long-standing.
          // ignore: experimental_member_use
          await migrator.alterTable(
            // ignore: experimental_member_use
            TableMigration(
              plans,
              columnTransformer: {
                plans.durationSec: const CustomExpression<int>(
                  'duration_min * 60',
                ),
              },
            ),
          );
        }
      },
    );
  }
}

@DriftAccessor(tables: [Plans])
class PlansDao extends DatabaseAccessor<AppDatabase> with _$PlansDaoMixin {
  PlansDao(super.db);

  Future<int> insertPlan(PlansCompanion plan) {
    return into(plans).insert(plan);
  }

  Future<int> updateStatusAndNoteById({
    required int id,
    required String status,
    String? note,
  }) {
    return (update(plans)..where((plan) => plan.id.equals(id))).write(
      PlansCompanion(status: Value(status), note: Value(note)),
    );
  }

  Future<Plan?> getActivePlan() {
    final query = select(plans)
      ..where((plan) => plan.status.equals('running'))
      ..orderBy([
        (plan) => OrderingTerm.desc(plan.startAt),
        (plan) => OrderingTerm.desc(plan.id),
      ])
      ..limit(1);

    return query.getSingleOrNull();
  }

  Future<Plan?> getPlanById(int id) {
    final query = select(plans)..where((plan) => plan.id.equals(id));

    return query.getSingleOrNull();
  }

  Stream<List<Plan>> watchPlansForDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    return watchPlansInRange(start: start, end: end);
  }

  Stream<List<Plan>> watchPlansInRange({
    required DateTime start,
    required DateTime end,
  }) {
    final query = select(plans)
      ..where((plan) {
        return plan.startAt.isBiggerOrEqualValue(start) &
            plan.startAt.isSmallerThanValue(end);
      })
      ..orderBy([
        (plan) => OrderingTerm.asc(plan.startAt),
        (plan) => OrderingTerm.asc(plan.id),
      ]);

    return query.watch();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'nudge.sqlite'));

    return NativeDatabase.createInBackground(file);
  });
}
