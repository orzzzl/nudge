# 08 — Auto check-in when the block ends

- **Status:** PLANNED (provisional — finalized to READY right before dispatch)
- **Owner:** Codex, or Claude if Codex is low on budget (Codex reviews)
- **Blocked by:** 07 (pending-action) + 11 (`getPlanById` to load the tapped plan) + 05
- **Allowed new deps:** none

## Goal
Right now check-in only happens when the user taps the capsule. Make it surface **automatically**
when the block actually ends — both in-app (countdown hits 0) and via the notification tap (task 07).

## Scope
- in:
  - In-app: when the active plan's remaining time reaches 0 while the app is open, auto-open the
    check-in sheet once (debounced — never spam, never re-open after dismissal until re-triggered).
  - Notification path: consume task-07's pending check-in action (a `planId`), load that plan via
    task-11's `getPlanById`, and open its check-in — works even after a cold start. This task owns
    "open the check-in"; task 07 only schedules + surfaces the `planId`.
- out:
  - No snooze yet; no change to how check-ins are recorded; no background execution beyond what
    the notification already provides.

## Acceptance criteria (draft)
- [ ] When `endAt` passes with the app open, the check-in sheet appears automatically, once.
- [ ] Tapping the notification opens the check-in for the correct plan.
- [ ] No duplicate/looping prompts; dismissing without choosing doesn't immediately re-open.
- [ ] Tests cover the auto-trigger + debounce logic.
- [ ] `dart format` / `flutter analyze` / `flutter test` all clean.

## Notes / hints
- Reuse the existing `showCheckInSheet` + `ChatController.checkIn` from task 05.
