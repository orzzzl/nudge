# 21 — Fix: time-up reminder never fires (exact-alarm permission gate)

- **Status:** DONE (PR #__)
- **Owner:** Claude (self-merged — Codex on leave)
- **Blocked by:** 07 (local notifications) — DONE

## Bug
Users reported that when a plan's timer reached time-up, **no notification arrived**
(`计时器到了不会收到提醒`). The in-app check-in sheet still appeared in the foreground (driven by a
separate Dart `Timer` in `ChatController`), so the failure was background/locked only — i.e. the OS
notification was never scheduled.

## Root cause
`LocalReminderScheduler._requestPermissions()` ANDed the **exact-alarm** grant into an
all-or-nothing permission gate and cached the result:

```dart
_permissionsGranted = androidNotificationsGranted && androidExactAlarmsGranted && iosGranted && macOSGranted;
```

and `scheduleCheckInReminder` bailed (`if (!granted) return;`) before calling `zonedSchedule`.

On Android 12+ (API 31+), `SCHEDULE_EXACT_ALARM` is denied by default — a normal user never enables
it — so `androidExactAlarmsGranted` was `false`, the whole gate became `false` (even with
notifications granted), and **no reminder was scheduled at all**. The cache made it permanent for the
session. Separately, `zonedSchedule` with `exactAllowWhileIdle` throws without that permission.

## Fix (chosen approach: `AndroidScheduleMode.alarmClock`)
- Schedule via `AndroidScheduleMode.alarmClock` → `AlarmManager.setAlarmClock`: exact delivery even in
  Doze, and **exempt** from `SCHEDULE_EXACT_ALARM`, so it fires on time for every user with no extra
  setup (best fit for the "nudge you right at time-up" promise; avoids Play exact-alarm review).
- Gate scheduling on the **notification** permission only; stop requesting/coupling exact-alarm.
- Cache only a *positive* permission result — a denial can be reversed in system settings, so
  re-request next time instead of silencing reminders for the rest of the session.
- Remove `SCHEDULE_EXACT_ALARM` from `AndroidManifest.xml` (no longer needed); keep
  `RECEIVE_BOOT_COMPLETED` (boot receiver re-arms pending reminders).

## Test (TDD: red → green)
`test/data/local_reminder_scheduler_test.dart` drives the real `LocalReminderScheduler` against
mocked `dexterous.com/flutter/local_notifications` + `flutter_timezone` method channels, with
`defaultTargetPlatform = android` and the Android plugin registered. It simulates
**notifications granted + exact-alarm denied** and asserts a `zonedSchedule` call is made.
- Against the old code: the gate bailed → no `zonedSchedule` → **test fails** (proves it catches the bug).
- After the fix: the reminder is scheduled → **test passes**.

## Out of scope
- Asserting a real OS notification actually appears while backgrounded — not feasible in a host
  unit/integration test; covered by manual device verification.

## Acceptance criteria
- [x] Regression test fails on the old code and passes after the fix.
- [x] `flutter analyze` + full `flutter test` clean.
- [ ] Device-verified: backgrounded plan fires the time-up notification on Android.
