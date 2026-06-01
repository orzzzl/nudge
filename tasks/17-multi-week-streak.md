# 17 — Unbounded (multi-week) streak

- **Status:** IN_REVIEW (PR #19, Claude — Codex reviews)
- **Owner:** Claude (Codex reviews)
- **Blocked by:** 06 (stats) — DONE.
- **Allowed new deps:** none.

## Goal
The 乖乖图 streak ("连续 N 天") currently resets every Monday: `_calculateStreak` only walks back
to `weekStart`, and the provider only queries the current week. So a run that crosses a Monday — e.g.
Fri/Sat/Sun/Mon — shows "连续 1 天" on Monday instead of 4. Make the streak **unbounded** (count back
across week/month boundaries until the first day with no planned block), with **all date math in
local time — no UTC anywhere** (the owner doesn't care about UTC; drift already round-trips `DateTime`
through an absolute epoch and hands back local `DateTime`s, so we keep bucketing by local calendar
day in Dart and never touch SQL `date()` / `.toUtc()`).

## Semantic (confirmed with owner)
A day counts toward the streak if it has **≥1 planned block**, regardless of outcome
(done/partial/missed/abandoned/running) — i.e. "你来了、安排了", not "你完成了". Unchanged from today.

## Scope (locked against real files)
- **`lib/features/stats/stats_providers.dart`** — widen the query so the streak can see history. Reuse
  the existing `watchPlansInRange` (no interface/DAO change, no new fakes): query
  `start: DateTime(2000)` (a local sentinel before any plan can exist) → `end: weekEnd`.
  `aggregateStats` already slices the current week back out of its input for the chart/ledger, so the
  week-scoped numbers are unaffected.
- **`lib/features/stats/stats_summary.dart`**:
  - Build `activeDays = { statsDayStart(p.startAt) for every plan p }` from the **full** input list
    (`statsDayStart` = local midnight, so this is correct in local time).
  - Rewrite `_calculateStreak(Set<DateTime> activeDays, DateTime today)`: start at `today` (or the
    previous calendar day if today has no block yet — keep the existing "today isn't over" grace),
    then walk backward **with no lower bound** while the day is in `activeDays`.
  - Step with a **calendar** decrement `DateTime(d.year, d.month, d.day - 1)`, NOT
    `subtract(Duration(days: 1))` — the latter is 24h arithmetic and lands off-midnight across a DST
    change, which would miss an `activeDays` key. Calendar decrement is DST-safe and stays local.
  - The week chart / ledger / completion / `plannedMinutes` logic is unchanged.

## Out of scope
- No change to the `PlanRepository` interface, the DAO, or any other screen.
- No new "longest-ever streak" stat, no streak freezes/grace beyond the existing today-grace.
- Not changing the weekly chart window — only the streak is unbounded.

## Acceptance criteria
- [ ] A run crossing a Monday boundary counts continuously (e.g. Fri+Sat+Sun+Mon ⇒ 4 on Monday).
- [ ] Streak still stops at the first day with no planned block; the existing today-grace
      (no block yet today ⇒ count from yesterday) is preserved.
- [ ] All date math is local; no UTC, no SQL `date()`, no `Duration(days:)` day-stepping in the walk.
- [ ] Existing `stats_summary_test` streak cases stay green; `stats_provider_test` updated for the
      widened query range (`lastStart` now the sentinel; `lastEnd` still `weekEnd`).
- [ ] New tests cover: cross-week run, a gap not connecting two separate weeks, and a long (>2 week)
      run.
- [ ] `dart format .` / `flutter analyze` / `flutter test` all clean.

## Notes / hints
- drift `dateTime()` default = unix-epoch storage; reads back as a **local** `DateTime`
  (`DateTime.fromMillisecondsSinceEpoch`), so `plan.startAt` is already local — keep it that way.
- This is logic-only (no visual change), so unit tests are the real verification; device-verifying a
  cross-week streak would need backdated plans the UI can't create.
