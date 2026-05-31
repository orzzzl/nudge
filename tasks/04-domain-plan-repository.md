# 04 — Domain layer: Plan entity + PlanRepository (over Drift)

- **Status:** READY
- **Owner:** Codex
- **Blocked by:** — (task 02 merged)
- **Allowed new deps:** none (drift + flutter_riverpod already present). Do NOT add freezed yet —
  hand-write the immutable entity.

## Goal
Put the Drift data layer behind a clean domain seam. This is the most important architectural
boundary in the app (`PlanRepository`, see tech-design §3): the UI and business logic will depend
ONLY on the domain interface, never on Drift. Add a pure-Dart `Plan` entity + `PlanStatus` enum,
the `PlanRepository` interface, a Drift-backed implementation that maps rows ↔ entities, and the
Riverpod providers that wire it. No UI.

## Scope
- in:
  - `lib/domain/plan.dart`:
    - `enum PlanStatus { running, done, partial, missed, abandoned }`
    - immutable `Plan` entity (hand-written: `final` fields, `const` constructor, `copyWith`,
      value `==`/`hashCode`). Fields: `int? id, String title, int durationMin, DateTime startAt,
      DateTime endAt, PlanStatus status, String? note, String locale, DateTime createdAt`.
      (`id` is null before insert.)
  - `lib/domain/plan_repository.dart` — abstract `PlanRepository`:
    - `Future<Plan> createPlan({required String title, required int durationMin,
       required DateTime startAt, required String locale})`
       — inserts a `running` plan with `endAt = startAt + durationMin minutes`,
       `createdAt = startAt`, `note = null`; returns the stored `Plan` (with its DB `id`).
    - `Future<void> checkIn({required int id, required PlanStatus status, String? note})`
       — updates status + note (the "结账").
    - `Stream<List<Plan>> watchPlansForDay(DateTime day)`
    - `Stream<List<Plan>> watchPlansInRange({required DateTime start, required DateTime end})`
  - `lib/data/repositories/plan_repository_impl.dart`:
    - `PlanRepositoryImpl implements PlanRepository`, constructed from a `PlansDao`.
    - Reuse the existing `PlansDao` (task 02) — do NOT change it.
    - Map Drift rows ↔ domain entities. The Drift-generated row class is ALSO named `Plan`, so
      import the db with a prefix (`import '../db/app_database.dart' as db;`) and map
      `db.Plan` → domain `Plan`. Status maps by `enum.name` ↔ the stored text; on an unknown
      status string, throw a clear `StateError` (we control all writes in the MVP).
  - `lib/app/providers.dart` (Riverpod):
    - `appDatabaseProvider` exposing a single `AppDatabase` (dispose it on provider dispose).
    - `planRepositoryProvider` returning `PlanRepositoryImpl(db.plansDao)`.
- out:
  - No UI, no notifications. Do not implement the other seams (`IntentParser`, `Notifier`,
    `PetRenderer`). Do not add a DAO for `PetConfigs`. Do not introduce freezed/json_serializable.

## Acceptance criteria
- [ ] Domain layer (`lib/domain/`) has zero imports from `package:drift` or `lib/data/` — verify it
      depends on nothing below it.
- [ ] `createPlan` returns a `Plan` whose `id` is non-null and whose `endAt` = `startAt` +
      `durationMin` minutes, `status == PlanStatus.running`.
- [ ] `checkIn` updates status + note for the given id.
- [ ] The two `watch*` streams return domain `Plan` objects (not Drift rows) and update reactively.
- [ ] `PlanStatus` round-trips through the DB text column for all five values.
- [ ] Unit tests use an in-memory `AppDatabase.forTesting(NativeDatabase.memory())` and cover:
      createPlan (id + computed endAt + default status), checkIn, reactive watch mapping, and
      status round-trip.
- [ ] `dart format` / `flutter analyze` / `flutter test` all clean.

## Notes / hints
- Keep the entity hand-written and small; `copyWith` only needs the fields above.
- The repository is the ONLY place that knows about Drift. If you find yourself importing
  `package:drift` outside `lib/data/`, stop — that breaks the seam.
- `createdAt = startAt` is fine for the MVP (a plan is created at the moment its block starts).
- Riverpod 3.x: a `Provider`/`Notifier` is fine; use `ref.onDispose` to close the database.
