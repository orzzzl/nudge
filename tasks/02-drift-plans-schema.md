# 02 — Drift database + Plans schema

- **Status:** DONE
- **Owner:** Codex
- **Blocked by:** — (task 01 merged)
- **Allowed new deps:** drift, sqlite3_flutter_libs, path_provider, path; dev: drift_dev, build_runner

## Goal
Add the local Drift (SQLite) database with the single `Plans` table that the whole MVP rests
on, plus a DAO exposing reactive queries. This is pure data layer — no UI.

## Scope
- in:
  - Define `Plans` table exactly per `docs/tech-design.md` §5 (id, title, durationMin, startAt,
    endAt, status[text, default 'running'], note[nullable], locale[text, default 'zh'], createdAt).
  - Define `PetConfigs` table per §5 (id, schemaVer[default 1], configJson[text], updatedAt).
  - Create the Drift `AppDatabase` (schemaVersion = 1) opened from the app documents dir.
  - Add a `PlansDao` with: insert plan, update status+note by id, watch plans for a given day
    (reactive `Stream`), and watch a date range (for stats aggregation later).
  - Add a `MigrationStrategy` placeholder (onCreate creates all tables; onUpgrade empty for now).
- out:
  - Do NOT implement `PlanRepository` yet (that interface comes in a later task). This task is
    the raw Drift layer only, under `lib/data/db/`.
  - No stats math, no notifications, no UI.

## Acceptance criteria
- [ ] `lib/data/db/app_database.dart` (+ generated `.g.dart`) compiles via build_runner.
- [ ] `Plans` and `PetConfigs` columns/types match docs/tech-design.md §5 exactly.
- [ ] Unit tests (using an in-memory Drift db) cover: insert, status update, watch-by-day emits
      updated results reactively.
- [ ] `status` and pet config stored as text/JSON (forward-compatible), not as enums/extra tables.
- [ ] `dart format` / `flutter analyze` / `flutter test` all clean.

## Notes / hints
- Use `NativeDatabase.memory()` for tests; real db via `path_provider` documents dir.
- Keep DAO methods returning domain-agnostic Drift rows; mapping to entities happens in the
  repository task, not here.
- `status` valid values (string contract): running | done | partial | missed | abandoned.
