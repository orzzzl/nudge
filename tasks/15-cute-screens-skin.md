# 15 — Cute skin across the screens (chat / stats / check-in / settings)

- **Status:** DONE (PR #18)
- **Owner:** Codex, or Claude if Codex is low on budget (Codex reviews)
- **Blocked by:** 14 (theme foundation + candy primitives)
- **Allowed new deps:** none (reuse task 14's foundation).

## Goal
With the theme foundation from task 14 in place, restyle each screen's **content** to match
`docs/mockups/cute.html` — the bespoke pieces a global theme can't give for free: gradient chat
bubbles, the countdown capsule, duration chips + start button, the stats hero/streak/bars/ledger, the
check-in card, and the settings rows. Use task 14's `CuteColors`, `candyShadow`, `CandyButton`,
`CandyCard` — **no new hexes at call sites**.

## Scope (locked against real files — exact widgets to restyle)

### Chat tab — `lib/features/chat/`
- `chat_screen.dart` `_MessageBubble`: three bubble styles from the mockup — `me` = peach gradient
  (`#FFB07C`→`#FF9B6A`) white text + peach candy shadow, bottom-right corner tightened; `ai` (greeting)
  = white, cream border, bottom-left tightened; the mascot confirmation (`ConfirmationMessage`) = mint
  `#EAFAF0` bg + mint border + green text. Keep the 团团 avatar (`PetView`) on AI rows.
- `widgets/countdown_capsule.dart`: white pill, peach border + peach candy shadow, tabular-numerals
  countdown in peach, the check-in button as a soft `#FFF2E4` mini-chip.
- `widgets/plan_composer.dart`: the task-name `TextField` as the cream `#FFF3E8` rounded field; the
  duration `ChoiceChip`s as candy chips (selected = peach gradient + shadow, unselected = white +
  peach border); the start button → `CandyButton` (green gradient, "开始这一格 ✓").

### Stats tab — `lib/features/stats/stats_screen.dart`
- `_PlannedHoursHero`: green-gradient (`#8AD6A3`→`#5CC78F`) `CandyCard` with green candy shadow, white
  text, big w900 number (matches the mockup hero).
- The streak: a peach/amber pill (`#FFF3E0` bg, `#FFE0B3` border, `#FFECD1` shadow) with 🔥 and
  `#E08A2E` bold text.
- `_WeeklyBars`: rounded green-gradient bars with green candy shadow; faint days in `#ECE3D8`.
- `_CompletionBar` + `_TodayLedger`: ledger as a white `CandyCard` with cream row dividers, status
  emoji at the end of each row.
- Section titles in muted brown w800 (`#A8917F`).

### Check-in sheet — `lib/features/chat/widgets/check_in_sheet.dart`
- Render as the mockup's centered card feel: rounded `#FFFDFA` card, 团团 on top, title + task line,
  the three answers (✅ done / 🍃 partial / 😴 missed) as bordered candy tiles with the mockup's
  per-answer colors (done mint, partial amber `#FFF6E6`/`#FFE1A8`, missed `#FDF0EE`/`#F3D4CD`), and the
  reassurance line ("选哪个都没关系，团团不会怪你的～"). Keep `showModalBottomSheet` + the
  `Future<PlanStatus?>` contract from task 05 unchanged — restyle internals only.

### Settings — `lib/features/settings/settings_screen.dart`
- Lighter touch: it inherits the theme. Group the DND / language / about into cute `CandyCard`
  sections with the rounded look; keep the existing controls (`SwitchListTile`,
  `SegmentedButton<LocaleOverride>`, About) and all behavior from task 10.

## Out of scope
- No behavior, data, i18n, or navigation changes — pixels only. Every existing callback/contract stays
  (`onStart`, `showCheckInSheet`→`PlanStatus?`, `controller.checkIn`, settings mutators, etc.).
- 团团 character art is task 16 (here `PetView` is used as-is).
- If the diff gets too large to review comfortably, split by tab into 15a (chat) / 15b (stats +
  check-in) / 15c (settings) PRs against the same task — note that in the PR.

## Acceptance criteria
- [ ] Each screen visibly matches the mockup's cute styling (bubbles, capsule, chips, hero, streak,
      bars, ledger, check-in card, settings cards).
- [ ] No hard-coded hex at call sites — broadly reused colors go into `CuteColors`; a widget that needs
      a one-off semantic palette (e.g. the check-in answer tiles' done/partial/missed triad) may hold
      it as a private `const` in its own file, not scattered at call sites.
- [ ] All existing behavior + widget/unit tests still pass; the check-in `Future<PlanStatus?>` and the
      composer `onStart` contracts are unchanged.
- [ ] `dart format .` / `flutter analyze` / `flutter test` all clean.

## Test impact (locked against the current tests — keep these green)
- `test/features/chat/chat_flow_test.dart` asserts the start button's disabled state via
  `tester.widget<FilledButton>(find.byType(FilledButton))`. Swapping the start button to `CandyButton`
  means updating that finder to `CandyButton` (expose `onPressed`); it still taps via
  `find.text(l10n.startButton)`, so keep the label exactly `l10n.startButton` (no appended glyph) and
  keep the duration chips' and check-in options' label text findable by `find.text`.
- `test/features/stats/stats_screen_test.dart` asserts `find.text('✅ ${statsStatusDone}')` — keep the
  ledger row's emoji+label in a SINGLE `Text` (`'$emoji $label'`), don't split them.

## Notes / hints
- Device-verify after this (see `docs/device-verify.md`) — screenshot each screen against the mockup.
- Reuse, don't reinvent: if a piece needs the candy shadow, call `candyShadow`; if it's a pill button,
  use `CandyButton`. Add a missing primitive to task-14's `candy.dart` rather than inlining a hex.
