# Post-mortem — time-up notification shipped silent ("通知不响")

- **Date:** 2026-06-02
- **Severity:** High — the core promise of the app (nudge you at time-up) silently failed for real users.
- **Status:** Root cause under confirmation; remediation tracked in [task 22](../tasks/22-notification-test-hardening.md).
- **Author:** Claude
- **Components:** `lib/data/notify/local_reminder_scheduler.dart`, notification CI coverage, release process.

## Summary

After rolling a build to a real phone, the time-up reminder did **not ring** — the notification
either did not surface audibly or did not surface at all on the device, even though it works in our
host test suite and on fresh installs. This is the **second** silent-notification incident in a row
(the first, [task 21 / PR #25](../tasks/21-timeup-notification-fix.md), was "the reminder never
fires" due to an exact-alarm permission gate). Both escaped because **no automated test exercises the
real on-device notification path**, and the manual device-verification step that was supposed to be
our backstop was not completed before release.

## Impact

- Users who relied on the time-up nudge got no audible reminder — the app silently failed at its one
  job for an unknown number of plans/sessions.
- Trust impact: a reminder app that doesn't remind is worse than no app, because the user *stopped
  watching the clock specifically because they expected the nudge*.
- Detection was external (noticed manually on a device after rollout), not by CI or any alert.

## Timeline (best known)

| When | What |
|------|------|
| earlier | Task 07 ships local notifications behind a `ReminderScheduler` seam. |
| earlier | **Incident #1:** users report the time-up reminder never fires. Root-caused to the Android 12+ exact-alarm gate. |
| pre-2026-06-02 | **PR #25 (task 21)** fixes incident #1 (switch to `AndroidScheduleMode.alarmClock`, gate on notification permission only). Its acceptance criteria list **"Device-verified: backgrounded plan fires the time-up notification on Android" — left UNCHECKED — and the PR is merged anyway.** |
| pre-2026-06-02 | Build rolled out to a phone. |
| 2026-06-02 | **Incident #2 (this one):** the time-up notification is observed not to ring on the device. |
| 2026-06-02 | This post-mortem written; remediation scoped as task 22. |

## Root cause

There are two layers, and the process one is the more important.

**Process root cause (confirmed).** We treat "does a real OS notification actually fire and ring on a
device" as *not feasible to automate* and therefore punt it to a manual device-verification step —
and then we ship without doing that step. Task 21's own spec says, verbatim: *"Asserting a real OS
notification actually appears … not feasible in a host unit/integration test; covered by manual
device verification,"* and its **"Device-verified" acceptance box was left unchecked at merge.** So the
single control that could have caught both incidents was optional, and was skipped. Two notification
fixes in a row were declared "done" on the strength of `flutter test` going green, which by
construction cannot observe a real notification.

**Technical root cause (leading hypothesis — to be confirmed in task 22).** In
`local_reminder_scheduler.dart` the Android channel is created as:

```dart
createNotificationChannel(const AndroidNotificationChannel(
  _channelId, _channelName, importance: Importance.high,
));
```

Android notification channels are **immutable after first creation** — once a channel id exists on a
device, later changes to its importance/sound are ignored until reinstall or a new channel id. If an
earlier build ever created `plan_check_in_reminders` with lower importance or no sound, an *updated*
install keeps the old, silent settings — which exactly matches "works on fresh installs / in tests,
silent after a rollout update." Runner-up causes to rule out: device DND/notification-category
settings, and reliance on the default sound that no test pins. Confirming the precise cause on a real
device is action item **A1** below.

## Why our tests didn't catch it (the detection gap)

- `test/data/local_reminder_scheduler_test.dart` mocks the platform method channel and asserts only
  **that `zonedSchedule` was *called***. It never asserts *what* was scheduled — not channel
  importance, not sound, not the fire time. A regression that keeps the call but drops the ringing
  passes green.
- The channel-creation call (`createNotificationChannel`) and its importance/sound are not asserted
  at all.
- `integration_test/db_smoke_test.dart` runs on a real device/emulator but only round-trips the DB;
  it never touches notifications.
- The whole "the notification actually posts and is audible on a device" path has **zero** automated
  coverage. Our test pyramid has a solid base and a missing top.

## What went well

- The `ReminderScheduler` domain seam (task 07) makes the scheduler swappable and unit-testable — the
  fix surface is well isolated, and a spy-based e2e is cheap to add.
- Incident #1 did get a real regression test (the exact-alarm gate), so that *specific* failure mode
  is now guarded.
- Per-second durations (PR #26) just landed, which makes a fast on-device "schedule 3s out, assert it
  posted" test actually practical — the enabling infra for the fix is already here.

## What went wrong

- A notification fix was merged with its device-verification acceptance box unchecked.
- "Tests green" was treated as equivalent to "feature works," for a feature whose failure mode is by
  definition invisible to host tests.
- We had already learned this lesson once (incident #1) and did not turn it into a durable control,
  so we relived it.

## Action items

Tracked in [task 22 — notification test & process hardening](../tasks/22-notification-test-hardening.md).

| # | Action | Type | Owner |
|---|--------|------|-------|
| A1 | Reproduce on a real device with a short (per-second) debug block; confirm whether the cause is channel immutability, DND, or sound config. Fix accordingly (version/recreate the channel when settings change; set sound explicitly). | Fix | Claude |
| A2 | Add a regression test that **fails on the current code and passes after the fix** (channel created with `Importance.high` **and** sound enabled). | Test | Claude |
| A3 | Upgrade the mocked-channel test from "called" → "called correctly": assert `zonedSchedule` channel id, `importance/priority high`, fire time == `plan.endAt`, payload == planId; assert iOS `presentSound: true`; assert the deny→no-schedule / grant→schedule matrix. | Test | Claude |
| A4 | New on-device notification smoke test in CI (Android emulator): schedule a ~3s-out reminder, wait, assert it actually **posted** via `getActiveNotifications()` / `adb shell dumpsys notification`, with sound + high importance on the channel. | Test | Claude |
| A5 | Time-up e2e with a **spy `ReminderScheduler`**: plan → countdown → time-up → assert `scheduleCheckInReminder(at: endAt)` fired → tap → check-in. | Test | Claude |
| A6 | **Process gate:** notification/reminder-touching PRs may **not** merge with an unchecked device-verification box. Add a short pre-rollout manual checklist (audibly rings, vibrates, shows on lock screen, **still rings after an app *update*** not just fresh install, behaves under DND) and make it a required release step. | Process | Claude |

## Lessons

1. **A feature whose failure is silent needs a test that can hear it.** If a host test cannot observe
   the real behavior, that is a signal to build the on-device test, not a license to skip
   verification.
2. **"Tests green" ≠ "feature works"** when the test only proves a method was called. Assert the
   *contents and effects*, not the call.
3. **Turn every incident into a durable control.** Incident #1 should have produced the on-device
   notification test and the merge gate; because it only produced a narrow unit test, incident #2
   followed. Task 22 closes this for good.
</content>
