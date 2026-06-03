import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nudge/data/db/app_database.dart';
import 'package:nudge/data/repositories/plan_repository_impl.dart';
import 'package:sqlite3/sqlite3.dart';

/// Guards the v1 -> v2 schema migration: durations moved from minutes
/// (`duration_min`) to seconds (`duration_sec`). The migration must backfill
/// the new column as `duration_min * 60` so existing plans keep their length.
void main() {
  test('v1 -> v2 converts duration_min minutes to duration_sec (×60)', () async {
    // Hand-build a v1 database: the old `plans` schema with durations in
    // minutes, plus the unchanged `pet_configs` table. DateTimes are stored as
    // unix-second integers (drift's default), and their exact value is
    // irrelevant here — only the duration conversion is under test.
    final raw = sqlite3.openInMemory();
    raw.execute('''
      CREATE TABLE plans (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        duration_min INTEGER NOT NULL,
        start_at INTEGER NOT NULL,
        end_at INTEGER NOT NULL,
        status TEXT NOT NULL DEFAULT 'running',
        note TEXT NULL,
        locale TEXT NOT NULL DEFAULT 'zh',
        created_at INTEGER NOT NULL
      );
    ''');
    raw.execute('''
      CREATE TABLE pet_configs (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        schema_ver INTEGER NOT NULL DEFAULT 1,
        config_json TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      );
    ''');
    const ts = 1717225200; // arbitrary unix seconds
    raw.execute(
      "INSERT INTO plans (title, duration_min, start_at, end_at, status, "
      "locale, created_at) VALUES "
      "('legacy 90m', 90, $ts, $ts, 'done', 'en', $ts), "
      "('legacy 30m', 30, $ts, $ts, 'running', 'zh', $ts)",
    );
    // Tell drift this is a v1 database so opening it runs onUpgrade(1, 2).
    raw.execute('PRAGMA user_version = 1');

    final database = AppDatabase.forTesting(NativeDatabase.opened(raw));
    addTearDown(database.close);
    final repository = PlanRepositoryImpl(database.plansDao);

    // The first query forces the migration to run.
    final plan90 = await repository.getPlanById(1);
    final plan30 = await repository.getPlanById(2);

    expect(plan90, isNotNull);
    expect(plan90!.title, 'legacy 90m');
    expect(plan90.durationSec, 90 * 60);

    expect(plan30, isNotNull);
    expect(plan30!.durationSec, 30 * 60);
  });
}
