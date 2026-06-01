# 08 — Auto check-in when the block ends

- **Status:** READY
- **Owner:** Codex, or Claude if Codex is low on budget (Codex reviews)
- **Blocked by:** 07 (`onCheckInTapped` + `takeInitialTappedPlanId`) + 11 (`getPlanById`) + 05 (`showCheckInSheet`, `ChatController.checkIn`) — all DONE
- **Allowed new deps:** none. (`fake_async` for tests is already available transitively via `flutter_test` — import `package:fake_async/fake_async.dart`.)

## Goal
Right now check-in only happens when the user taps the capsule's check-in button. Make it surface
**automatically** when the block actually ends — both in-app (the countdown reaches 0 while the app
is open) and via the notification tap from task 07 (works after a cold start too).

## Design (locked against the real interfaces)
All trigger logic lives in `ChatController` so it is unit-testable; `ChatScreen` only opens the
sheet. There is **one** notion of "a plan that needs check-in right now":

### Controller changes — `lib/features/chat/chat_controller.dart`
- Add `Plan? pendingCheckIn` to `ChatState` (+ `copyWith`, with a `clearPendingCheckIn` flag mirroring
  the existing `clearActivePlan` pattern).
- Add a debounce guard so each plan auto-prompts **at most once**: track the last prompted plan id
  (e.g. `int? _lastPromptedPlanId`). `consumePendingCheckIn()` clears `pendingCheckIn` but does **not**
  clear the guard — so dismissing the sheet does not immediately re-open it.
- `_promptCheckIn(Plan plan)`: no-op if `plan.id == _lastPromptedPlanId`, if `plan.id == null`, or if
  `plan.status != PlanStatus.running` (the plan was already checked in). Otherwise set
  `_lastPromptedPlanId = plan.id` and `state = state.copyWith(pendingCheckIn: plan)`.
- **In-app trigger:** when an active plan is set (in `createPlan`) or restored (in
  `_restoreActivePlan`), arm a single one-shot `Timer` for `plan.endAt.difference(DateTime.now())`.
  If that duration is already `<= 0` (the block ended while the app was closed/backgrounded), call
  `_promptCheckIn(plan)` immediately (synchronously, no timer). On fire, call `_promptCheckIn(plan)`.
  Cancel/replace the timer in `checkIn` and on any new active plan; register `ref.onDispose` to cancel it.
- **Notification trigger (warm/background tap):** in `build()`, subscribe to
  `_reminderScheduler.onCheckInTapped` (a `Stream<int>` of planId). For each planId, load the plan via
  `_repository.getPlanById(planId)` and, if non-null, call `_promptCheckIn`. Cancel the subscription in
  `ref.onDispose`.
- **Notification trigger (cold start):** in `build()` (alongside `_restoreActivePlan`), call
  `_reminderScheduler.takeInitialTappedPlanId()`; if it returns a planId, `getPlanById` → `_promptCheckIn`.
- `consumePendingCheckIn()`: `state = state.copyWith(clearPendingCheckIn: true)`.
- `checkIn(status)`: unchanged behavior, but also clear `pendingCheckIn` and cancel the timer when it
  clears the active plan (a recorded check-in should never leave a stale pending prompt).

### Screen changes — `lib/features/chat/chat_screen.dart`
- Convert to a `ConsumerStatefulWidget` (so `ref.listen` can live in `build` without re-fires causing
  multiple sheets), or use `ref.listen` directly in the existing `build`. Listen on
  `chatControllerProvider.select((s) => s.pendingCheckIn)`. When it transitions to a non-null `Plan`,
  call `showCheckInSheet(context, plan: plan)`; await it; if a `PlanStatus` was chosen, call
  `controller.checkIn(status)`. **Always** call `controller.consumePendingCheckIn()` afterward
  (whether chosen or dismissed). Guard against re-entrancy so only one sheet is open at a time.
- The existing manual `_checkIn` (capsule button) path stays as-is.

## Out of scope
- No snooze. No change to how check-ins are recorded (`PlanRepository.checkIn` is untouched). No new
  background execution beyond the notification task 07 already schedules.

## Acceptance criteria
- [ ] When `endAt` passes with the app open, the check-in sheet appears automatically, exactly once.
- [ ] A plan whose `endAt` is already past when restored on launch prompts immediately (once).
- [ ] Tapping the notification (warm or cold start) opens the check-in for the correct plan, loaded
      via `getPlanById`.
- [ ] Dismissing the sheet without choosing does **not** immediately re-open it; the manual capsule
      check-in still works.
- [ ] A tapped/expired plan that is already checked in (`status != running`) does **not** prompt.
- [ ] Unit tests (in `test/features/chat/`) cover: in-app auto-trigger (use `fake_async` to advance
      past `endAt`), immediate prompt on restore-past-end, the `onCheckInTapped` stream path, the
      `takeInitialTappedPlanId` cold-start path, the once-only debounce, and the
      already-checked-in skip. The existing `_RecordingReminderScheduler` fake already exposes
      `_tapController` (push planIds) and a settable `initialTappedPlanId` — extend it if needed.
- [ ] `dart format .` / `flutter analyze` / `flutter test` all clean.

## Notes / hints
- Reuse `showCheckInSheet` (`lib/features/chat/widgets/check_in_sheet.dart`) and
  `ChatController.checkIn` from task 05 — do not build a second check-in UI.
- `dart:async` is already imported in the controller; `unawaited(...)` is already used in `build()`.
- Keep `_restoreActivePlan`'s existing guard (`state.activePlan != null` → bail) intact when wiring
  the timer so a manually-created plan isn't clobbered by a slow restore.
