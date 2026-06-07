# 11 — Active-plan persistence (survive app restart)

- **Status:** DONE (reviewed by Claude; merged in PR #10)
- **Owner:** Codex
- **Blocked by:** 04 (extends the repository interface)
- **Allowed new deps:** none
- **Sequencing:** do this BEFORE 07/08 — they need the repo reads this task adds (load a plan by id
  / find the active plan), otherwise a notification tapped after cold start has no way to open the
  right plan.

## Goal
Today the active (running) plan lives only in in-memory `ChatController` state, so killing the app
loses the countdown. On launch, restore the running plan — show its capsule (or prompt check-in if
its block already ended).

## Scope
- in:
  - **DAO** (`PlansDao`): add two read queries — the latest plan with status `running`
    (`order by startAt desc limit 1`), and a select by `id`.
  - **Domain** (`PlanRepository`, in `lib/domain`): add `Future<Plan?> getActivePlan()` and
    `Future<Plan?> getPlanById(int id)` (interface change — Claude reviews the seam).
  - **Impl** (`PlanRepositoryImpl`): implement both, mapping `db.Plan` → domain `Plan` (reuse the
    existing `_mapRow`).
  - **Restore on launch** in `ChatController`: `build()` still returns the initial state
    synchronously (greeting, no active plan), then kicks off an async restore that calls
    `getActivePlan()` and, if non-null, sets `state = state.copyWith(activePlan: restored)` so the
    countdown capsule reappears. Fire-and-forget from `build()`; guard against clobbering a plan the
    user may have created in the meantime (only restore if `state.activePlan` is still null).
- out:
  - No full transcript restore — just bring back `activePlan` so the task-05 capsule shows. No
    multi-plan view, no editing.
  - No new auto-check-in behavior: if the restored `endAt` is already past, the existing task-05
    capsule already renders "time's up" and its check-in button works — that's enough here.
    (Auto-firing the sheet is task 08; do NOT build it now.)

## Acceptance criteria
- [ ] `getActivePlan()` returns the latest `running` plan (or null); `getPlanById` returns the
      matching plan (or null). Both covered by repo tests over an in-memory db.
- [ ] After a running plan exists, a freshly built `ChatController` restores it into `activePlan`
      (capsule shows) — covered by a controller/widget test with an overridden in-memory repo.
- [ ] Checking in the restored plan works and clears it; the composer returns.
- [ ] A restored plan whose `endAt` already passed shows the task-05 "time's up" capsule (no crash,
      no auto-sheet).
- [ ] `dart format` / `flutter analyze` / `flutter test` all clean.

## Notes / hints
- The new repo method is an interface change — keep it minimal and in `lib/domain`.
- Only one plan should be `running` at a time; enforce/assume that in the query.
