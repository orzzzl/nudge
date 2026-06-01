# 10 — Settings + 勿扰 (do-not-disturb)

- **Status:** PLANNED (provisional — finalized to READY right before dispatch)
- **Owner:** Codex, or Claude if Codex is low on budget (Codex reviews)
- **Blocked by:** 03 (i18n), 05
- **Allowed new deps:** shared_preferences (or reuse Drift for a small settings store — decide at spec time)

## Goal
Add the ⚙️/🌙 entry and a minimal settings surface: a do-not-disturb toggle, a manual language
override (zh / en / follow system), and a basic about section.

## Scope
- in:
  - A settings entry (icon in the chat app bar) → a settings screen.
  - A small persisted settings store (survives restart).
  - **Do-not-disturb** toggle — for now it just stores the preference (it will gate future
    re-engagement notifications; the per-plan reminder from task 07 stays user-controllable).
  - **Language override** — zh / en / system; drives `MaterialApp.locale` live.
  - **About** — app name, version.
  - i18n for all settings strings.
  - Tests: settings store round-trip + the language override switching locale.
- out:
  - No re-engagement notifications yet (so DND only stores the pref). No account/profile. No themes.

## Acceptance criteria (draft)
- [ ] Settings persist across an app restart.
- [ ] Language override switches the UI locale immediately and persists.
- [ ] DND toggle is stored and readable by other code.
- [ ] All strings i18n'd; no Chinese outside `*.arb`.
- [ ] `dart format` / `flutter analyze` / `flutter test` all clean.

## Notes / hints
- Keep the settings store behind a small provider so task 07/future re-engagement can read DND.
