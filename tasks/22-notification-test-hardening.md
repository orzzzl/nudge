# 22 — Notification test & process hardening (post-mortem follow-up)

- **Status:** READY
- **Owner:** Claude (self-merged — Codex on leave)
- **Blocked by:** 07 (local notifications) — DONE; 21 (time-up fix) — DONE; 20 (per-second durations, enables fast on-device timing) — DONE
- **Allowed new deps:** none (use existing `flutter_local_notifications`, `integration_test`; `adb` is available on the CI emulator)

## Goal

Close the gap that let two silent-notification incidents reach users (see
[`docs/postmortem-2026-06-02-silent-notification.md`](../docs/postmortem-2026-06-02-silent-notification.md)).
The reminder is the app's core promise; its failure mode is invisible to host tests, so we must
(a) confirm and fix the live "通知不响" bug, (b) assert *what* we schedule, not just *that* we
schedule, (c) add automated on-device coverage of the real notification path, and (d) make manual
device verification a non-skippable release gate.

## Scope

- in: A1–A6 below.
- out: redesigning the notification UX; iOS on-device notification automation (simulator notification
  introspection is unreliable — iOS stays manual-checklist for now); re-engagement / morning nudges.

### A1 — Confirm & fix the live bug
- Reproduce on a real device using a short per-second debug block (durations from PR #26 make this
  fast). Determine the cause among: **Android channel immutability** (channel created once with low
  importance/no sound, later code changes ignored on updated installs), device DND, or unset sound.
- Fix accordingly. If immutability: recreate the channel when its definition changes (delete +
  recreate, or version the channel id) and set `playSound` explicitly. Keep `Importance.high`.

### A2 — Regression test for the live bug
- A test that **fails on the pre-fix code and passes after** — assert the channel is created with
  `Importance.high` **and** sound enabled (and, if A1 lands a channel-versioning fix, that a stale
  channel is recreated).

### A3 — Strengthen the mocked-channel unit test ("called" → "called correctly")
In `test/data/local_reminder_scheduler_test.dart`, assert the captured `MethodCall` arguments:
- `zonedSchedule`: correct channel id, `importance`/`priority` high, **fire time == `plan.endAt`**
  (guards timezone + `durationSec` math), `payload == planId`.
- iOS path (`defaultTargetPlatform = iOS`, iOS plugin registered): `presentSound: true`.
- Permission matrix: notifications **denied → no `zonedSchedule`**; granted → scheduled.

### A4 — On-device notification smoke test (CI, Android)
- New `integration_test/notify_smoke_test.dart`, run on the existing Android emulator job (mirror the
  `db_smoke` harness in `.github/workflows/db-smoke.yml`).
- Schedule a reminder ~3s out, wait, then assert it **actually posted** via
  `getActiveNotifications()` (and/or `adb shell dumpsys notification`), with sound + high importance
  on the channel.

### A5 — Time-up e2e with a spy scheduler
- Using a spy `ReminderScheduler`, drive plan → countdown → time-up and assert
  `scheduleCheckInReminder(at: endAt)` fired with the right args → tap → check-in. Catches "we never
  even asked to schedule."

### A6 — Process gate (release)
- Notification/reminder-touching PRs may **not** merge with an unchecked device-verification box.
- Add a pre-rollout manual checklist (extend [`docs/device-verify.md`](../docs/device-verify.md)):
  audibly **rings**, vibrates, shows on lock screen, **still rings after an app *update*** (not just a
  fresh install), and behaves under DND. Make it a required release step.

## Acceptance criteria

- [ ] A1: live bug reproduced on a device, root cause confirmed, fix landed.
- [ ] A2: regression test fails on pre-fix code, passes after.
- [ ] A3: unit test asserts channel id / importance / sound / fire-time==endAt / payload / iOS
      `presentSound` / permission matrix.
- [ ] A4: on-device Android test schedules and verifies a *posted* notification in CI.
- [ ] A5: time-up e2e with a spy scheduler asserts the full plan→time-up→schedule→tap→check-in chain.
- [ ] A6: device-verify checklist updated and made a required merge/release gate; this PR (and future
      notification PRs) device-verified with the box checked.
- [ ] `flutter analyze` + full `flutter test` clean.

## Notes / hints

- Scheduler: `lib/data/notify/local_reminder_scheduler.dart`; seam: `lib/domain/reminder_scheduler.dart`.
- Channel id today: `plan_check_in_reminders` (const `_channelId`). Changing it *is* the
  channel-versioning fix for immutability — but it orphans the old channel, so prefer
  delete-then-recreate keyed on a definition hash if feasible.
- Existing mocked-channel pattern (method channel `dexterous.com/flutter/local_notifications`,
  `flutter_timezone`, `debugDefaultTargetPlatformOverride`) is already in
  `test/data/local_reminder_scheduler_test.dart` — extend it, don't rebuild it.
- Android-only emulator path mirrors `db-smoke.yml`; iOS notification automation is intentionally out
  of scope (manual checklist instead).
</content>
