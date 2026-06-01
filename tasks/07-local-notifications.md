# 07 — Local notifications (the `Notifier` seam)

- **Status:** PLANNED (provisional — finalized to READY right before dispatch)
- **Owner:** Codex, or Claude if Codex is low on budget (Codex reviews)
- **Blocked by:** 05
- **Allowed new deps:** flutter_local_notifications, timezone, flutter_timezone (or equivalent)

## Goal
Make the product's core promise — "时间到了提醒你" — real, on-device. When a plan starts, schedule
a local notification at its `endAt`; tapping it deep-links to that plan's check-in. Define the
`Notifier` seam so a future remote/region-split push can drop in without touching callers.

## Scope
- in:
  - `lib/domain/notifier.dart` — abstract `Notifier`:
    `scheduleCheckInReminder({required int planId, required String title, required DateTime at})`
    and `cancel(int planId)`.
  - `lib/data/notify/local_notifier.dart` — impl over `flutter_local_notifications` + `timezone`:
    notification channel, zoned scheduling at `endAt`, request runtime permissions (iOS +
    Android 13+ `POST_NOTIFICATIONS`; `SCHEDULE_EXACT_ALARM` where applicable).
  - Wire it into the flow: schedule on plan create, cancel on check-in. (Coordinate with the chat
    controller via a provider; do not break the task-04 seam.)
  - Tap → deep-link to the check-in for that plan (go_router route or a pending-action provider).
  - Android manifest + iOS AppDelegate plumbing.
- out:
  - No remote/FCM/push (post-MVP, China needs vendor channels). No re-engagement nudges.
  - Just the per-plan end-of-block reminder.

## Acceptance criteria (draft)
- [ ] Scheduling + cancel go through the `Notifier` interface; callers don't import the plugin.
- [ ] Permissions requested/handled on both platforms; respects timezone.
- [ ] Tapping the notification opens the check-in for the right plan.
- [ ] Seam is unit-tested with a fake `Notifier`; document what can't be unit-tested (platform).
- [ ] `dart format` / `flutter analyze` / `flutter test` all clean.

## Notes / hints
- Mind iOS scheduling limits and Android Doze / exact-alarm permission UX.
- Keeping this behind `Notifier` is the whole point — remote push (region adapters) comes later.
