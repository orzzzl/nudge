# 07 — Local notifications (the reminder seam)

- **Status:** READY
- **Owner:** Codex (Claude does the on-device verification)
- **Blocked by:** 05
- **Allowed new deps:** flutter_local_notifications, timezone, flutter_timezone

## Goal
Make the product's core promise — "时间到了提醒你" — real, on-device. When a plan starts, schedule a
local notification at its `endAt`. Tapping it surfaces the plan's id so task 08 can open the
check-in. Keep it behind a seam so future remote/region-split push drops in without touching callers.

## Naming (locked — avoid a collision)
Do NOT call the seam `Notifier` — that's Riverpod's class (`ChatController extends Notifier`). Name
the interface **`ReminderScheduler`**.

## Scope
- in:
  - `lib/domain/reminder_scheduler.dart` — abstract `ReminderScheduler` (pure Dart, NO Flutter):
    - `Future<void> scheduleCheckInReminder({required int planId, required String title, required DateTime at})`
    - `Future<void> cancel(int planId)`
    - `Stream<int> get onCheckInTapped` — emits the `planId` of a tapped reminder (foreground/bg).
    - `Future<int?> takeInitialTappedPlanId()` — a planId if the app was cold-started by tapping a
      reminder (consumed once), else null.
  - `lib/data/notify/local_reminder_scheduler.dart` — impl over `flutter_local_notifications` +
    `timezone` + `flutter_timezone`:
    - init the plugin + one Android notification channel; init `timezone` with the device's local
      zone (via flutter_timezone).
    - `zonedSchedule` at `at` with exact scheduling (`AndroidScheduleMode.exactAllowWhileIdle`).
    - request permissions lazily on first schedule: iOS (alert/badge/sound) + Android 13+
      `POST_NOTIFICATIONS` + Android 12+ exact-alarm.
    - the notification payload is the `planId` (string); the tap callback parses it onto
      `onCheckInTapped`; `getNotificationAppLaunchDetails` feeds `takeInitialTappedPlanId`.
  - `reminderSchedulerProvider` (Riverpod) exposing the `ReminderScheduler` singleton; initialize it
    once at app start (in `lib/app/`).
  - Wire into `ChatController` (inject via the provider):
    - after `createPlan` succeeds → `scheduleCheckInReminder(planId: plan.id!, title: trimmed, at: plan.endAt)`.
    - in `checkIn` → `cancel(id)` for the plan being checked in.
  - Platform plumbing: Android manifest (`POST_NOTIFICATIONS`, `USE_EXACT_ALARM`/
    `SCHEDULE_EXACT_ALARM`, the flutter_local_notifications receivers) + iOS `AppDelegate` /
    Info.plist exactly as the plugin's README requires.
- out:
  - Does NOT open the check-in sheet and does NOT load the plan — task 08 consumes `onCheckInTapped`
    / `takeInitialTappedPlanId` and uses task-11 `getPlanById`.
  - No remote/FCM/push (post-MVP). No re-engagement nudges. No snooze.

## Acceptance criteria
- [ ] `ReminderScheduler` is a pure-Dart interface in `lib/domain` (no Flutter import); the impl in
      `lib/data/notify` is the only place that imports the plugin.
- [ ] `ChatController` schedules on create and cancels on check-in, via the provider — covered by a
      unit test with a fake `ReminderScheduler` (assert schedule/cancel called with the right args).
- [ ] Tapped `planId` is exposed via `onCheckInTapped` + `takeInitialTappedPlanId` (07 stops there;
      task 08 opens the UI).
- [ ] Timezone-correct scheduling; permissions requested on both platforms.
- [ ] `dart format` / `flutter analyze` / `flutter test` all clean. State in the PR what can't be
      unit-tested (actual on-device delivery — Claude verifies on a device).

## Notes / hints
- Mind iOS scheduling limits + Android Doze / exact-alarm permission UX.
- **Pin plugin versions deliberately** — remember the `sqlite3_flutter_libs` `0.6.0+eol` trap; verify
  a version actually works on-device, don't just take "latest".
- Don't break the task-04 repository seam or change the domain `Plan`.
