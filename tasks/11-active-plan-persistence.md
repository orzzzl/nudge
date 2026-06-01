# 11 — Active-plan persistence (survive app restart)

- **Status:** PLANNED (provisional — finalized to READY right before dispatch)
- **Owner:** Codex, or Claude if Codex is low on budget (Codex reviews)
- **Blocked by:** 04 (extends the repository interface)
- **Allowed new deps:** none

## Goal
Today the active (running) plan lives only in in-memory `ChatController` state, so killing the app
loses the countdown. On launch, restore the running plan — show its capsule (or prompt check-in if
its block already ended).

## Scope
- in:
  - Extend `PlanRepository` with an active-plan query, e.g. `Future<Plan?> getActivePlan()` /
    `Stream<Plan?> watchActivePlan()` returning the latest plan with status `running`
    (interface change — Claude reviews the seam).
  - On `ChatController` build, load the active plan and restore `activePlan` (rebuild the capsule).
  - If the restored plan's `endAt` is already past, coordinate with task 08 to prompt check-in.
- out:
  - No full history/transcript restore (just the active plan + capsule). No multi-plan view.

## Acceptance criteria (draft)
- [ ] Create a plan, kill & relaunch → the capsule is restored with the correct remaining time.
- [ ] Checking in the restored plan works and clears it.
- [ ] If `endAt` already passed, the user is led to check in (not left with a stale capsule).
- [ ] Repository + controller covered by tests over an in-memory db.
- [ ] `dart format` / `flutter analyze` / `flutter test` all clean.

## Notes / hints
- The new repo method is an interface change — keep it minimal and in `lib/domain`.
- Only one plan should be `running` at a time; enforce/assume that in the query.
