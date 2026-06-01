# 05 — Build-plan + check-in core loop (chat UI)

- **Status:** DONE (implemented by Claude; reviewed by Codex; merged in PR #6)
- **Owner:** Claude (role swap this round — Codex reviews)
- **Blocked by:** — (task 04 merged)
- **Allowed new deps:** none

## Goal
Turn the placeholder Chat tab into the real core loop: set a 1–2h plan with a **fixed-format**
input (task-name field + duration buttons, NO sentence parsing / no AI), see a confirmation +
countdown, and **check in** (✅/🍃/😴). All on top of the task-04 `PlanRepository`. In-app only —
no OS notifications and no Rive yet (those are later tasks; use a simple 🌱 emoji for 团团).

## Scope
- in:
  - `ChatController` (Riverpod `Notifier<ChatState>`) in `lib/features/chat/`:
    - state = `{ List<ChatMessage> messages, Plan? activePlan }`
    - `createPlan(title, durationMin)` → `repo.createPlan(startAt: DateTime.now(), locale: <ui locale>)`,
      appends a user bubble + a 团团 confirmation bubble, sets `activePlan`.
    - `checkIn(PlanStatus)` → `repo.checkIn(activePlan.id, status)`, appends a result bubble,
      clears `activePlan`.
    - depends on `planRepositoryProvider` (task 04).
  - Chat screen (`chat_screen.dart`) rewrite:
    - a scrolling list of message bubbles (AI bubbles get a 🌱 avatar; user bubbles right-aligned).
    - when `activePlan == null`: show the fixed-format **composer** — a task-name `TextField`,
      a row of duration chips (30 / 60 / 90 / 120 min, one selected), and a "start" button.
      Start is disabled until the task name is non-empty.
    - when `activePlan != null`: show a **countdown capsule** with the title + remaining time
      (updates ~1/sec via a local timer) and a "结账 / check-in" button. Capsule may show a
      "time's up" state if remaining ≤ 0; the button works at any time (early check-in allowed).
    - check-in: the button opens a modal sheet with three options (✅ done / 🍃 partial / 😴 missed)
      + a non-judgmental reassurance line; picking one calls `checkIn(...)`.
  - i18n: every visible string via ARB. Add the new keys to `app_en.arb` (template, with `@`
    descriptions) AND `app_zh.arb`. Use ARB placeholders for the confirmation (title + minutes).
  - tests in `test/features/chat/`: drive the loop with the real repo over an in-memory db
    (override `planRepositoryProvider`): enter a title → tap a duration → start → assert
    confirmation bubble + capsule appear; open check-in → pick done → assert `activePlan` cleared
    and a result bubble appears.
- out:
  - No OS notifications / background scheduling (that's the `Notifier` seam — later task).
  - No Rive 团团 (later task) — a 🌱 emoji placeholder is fine.
  - No stats/charts (task 06). No settings / 勿扰. No editing or deleting plans.
  - Do not change the domain, repository, or DAO.

## Acceptance criteria
- [ ] Entering a task name + tapping a duration + start creates a plan via `PlanRepository` and
      shows a confirmation bubble + countdown capsule; the composer is hidden while a plan is active.
- [ ] The start button is disabled when the task-name field is empty.
- [ ] Check-in offers done/partial/missed, calls `checkIn`, clears the active plan, and appends a
      result bubble; the composer returns for the next plan.
- [ ] No hard-coded user-facing strings; new keys exist in both `app_en.arb` and `app_zh.arb`;
      no Chinese outside `*.arb`.
- [ ] Widget test covers the create → check-in loop with an overridden in-memory repository.
- [ ] `dart format` / `flutter analyze` / `flutter test` all clean.

## Notes / hints
- Keep widgets small and in `lib/features/chat/` (one controller file, the screen, and a couple of
  small widget files: composer, capsule, check-in sheet).
- Read the current UI locale via `Localizations.localeOf(context)` to pass `locale` to createPlan.
- The countdown is display-only; check-in is user-initiated (no auto-fire yet — that needs the
  notification seam).
