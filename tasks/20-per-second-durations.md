# 20 — Per-second durations + minutes/hours picker

- **Status:** IN_REVIEW (PR #__)
- **Owner:** Claude (self-merged — Codex on leave)
- **Blocked by:** 02 (Drift schema), 05 (composer) — DONE

## Goal
Let users pick a plan duration in **minutes** (default) or **hours**, and store durations
internally in **seconds** so we can also create very short blocks (a few seconds) for manual and
e2e testing of the time-up → check-in/notification flow. Seconds is an internal concept only —
users never pick seconds in release builds.

## Design
- **Storage unit = seconds.** `Plan.durationMin` → `durationSec`; Drift column `duration_min` →
  `duration_sec`; `createPlan` takes `durationSec` and computes `endAt = startAt + durationSec`.
  Countdown/notification already key off `endAt`, so short blocks "just work".
- **Migration (schemaVersion 1 → 2):** recreate `plans` via `TableMigration`, backfilling
  `duration_sec` from `CustomExpression('duration_min * 60')` so existing plans keep their length.
- **Stats** sum `durationSec`; `StatsSummary` stores `plannedSeconds` and exposes `plannedMinutes`
  (`~/60`) + `plannedHours` (`/3600`) getters, so `pet_mood` and the hero label are unchanged.
- **Display:** `formatPlanDuration(l10n, seconds)` — whole hours read "2 hr", sub-minute (debug)
  "30 sec", else whole minutes "90 min". `planConfirmation`/`checkInTaskLine` now take a preformatted
  `{duration}` string.
- **Composer:** a minutes/hours unit toggle (seconds is added only in `kDebugMode`), per-unit preset
  chips (min: 30/60/90/120, hr: 1/2/3/4, sec: 10/30/60/120), and a custom amount field that overrides
  the presets. `onStart` reports `durationSec`. The title field gets a `Key('composerTitleField')`
  now that there are two text fields.

## Tests
- `test/data/db/migration_test.dart` hand-builds a v1 DB (raw `sqlite3`, `NativeDatabase.opened`) and
  asserts v1→v2 converts `duration_min` minutes to `duration_sec` (×60), preserving each plan.
- All existing unit/widget tests migrated to seconds (minute literals × 60); `plannedMinutes`
  assertions hold via the getter.

## Out of scope
- The time-up e2e (front-flow + spy scheduler) that short durations enable — follow-up task.
- Fractional custom amounts (e.g. 1.5 h) — use minutes for sub-hour precision.

## Acceptance criteria
- [x] Durations stored in seconds end-to-end; `endAt` second-accurate.
- [x] v1→v2 migration preserves existing durations (×60), covered by a test.
- [x] Composer offers minutes/hours (seconds only in debug) + custom amount.
- [x] `flutter analyze` + full `flutter test` clean.
- [ ] Device-verified: composer picker + a short debug block reaches time-up.
