# 14 — Cute theme foundation (palette + fonts + candy primitives + shell)

- **Status:** READY
- **Owner:** Codex, or Claude if Codex is low on budget (Codex reviews)
- **Blocked by:** — (all the screens it restyles already exist)
- **Allowed new deps:** `google_fonts` (^6.x). No others.

## Goal
The app currently uses stock Material 3 (`ColorScheme.fromSeed(seedColor: Colors.teal)`) and looks
nothing like the approved mockup `docs/mockups/cute.html` (live:
https://orzzzl.github.io/nudge/mockups/cute.html). Build the **visual foundation** — the macaron
palette, rounded typography, the soft gradient background, and the signature "candy" hard-offset
shadow primitives — and apply it to the shared shell (top app bar + bottom tab bar). Per-screen
content restyling is task 15; the 团团 character art is task 16. This task makes everything that
follows a matter of *using* the foundation.

## The palette (from cute.html — lock these exact hexes)
Put them as `const Color` values in a `CuteColors` holder (e.g. in `lib/app/app_theme.dart` or a new
`lib/app/cute_palette.dart`):
- Background cream `#FFF7EF`; gradient blobs peach `#FFE9D6`, matcha `#E2F5E6`, lavender `#F3E6FF`.
- Surface/card `#FFFDFA`, pure white `#FFFFFF`.
- Matcha green: brand/text `#3F7D5C`, vivid `#2E9E6B`, gradient `#8AD6A3`→`#5CC78F`, candy-shadow `#4FB87F`.
- Peach: gradient `#FFB07C`→`#FF9B6A`, candy-shadow `#F08A55`.
- Text brown `#5A4A3F`; muted `#B6A395` / `#A8917F`; faint `#CDB9A8` / `#C4B09C`.
- Borders: cream `#F4E7D8`, peach `#FFE0C2` / `#FFE3CD`, mint `#C4EBD1`, neutral `#EADFD2`.
- Mint confirm bg `#EAFAF0`; field bg `#FFF3E8` / `#FFF2E4`.

## Scope (locked against real files)

### Typography — `google_fonts`
- Add `google_fonts: ^6.x` to `pubspec.yaml` deps; `flutter pub get`.
- Build the `TextTheme` from a rounded face — **Baloo 2** for Latin, with a rounded Chinese fallback
  (e.g. `GoogleFonts.zcoolKuaiLe`) wired via `fontFamilyFallback` so zh text is also rounded. Heavy
  weights everywhere (the mockup runs w700–w900): titles w800/w900, body w600/w700.

### `lib/app/app_theme.dart` — full `ThemeData`
- Replace the bare seed with a hand-tuned `ColorScheme.light` (or `fromSeed` + `copyWith`) mapping the
  palette: `primary`/`tertiary` = matcha greens, `secondary` = peach, `surface` = `#FFFDFA`,
  `onSurface` = `#5A4A3F`, `onSurfaceVariant` = `#B6A395`, etc. `scaffoldBackgroundColor` =
  transparent (the gradient background shows through — see below).
- Set chunky shapes globally: `cardTheme`, `chipTheme`, `inputDecorationTheme`,
  `bottomSheetTheme`, `dialogTheme` with large radii (cards/sheets ~26, chips/fields ~16–18,
  bubbles handled per-widget in task 15). Rounded, friendly.
- `appBarTheme`: transparent/cream background, no elevation, brand-green title, centered or
  leading-aligned per the shell below.
- `navigationBarTheme`: cream surface, the active "pill" indicator in mint `#EAFAF0`, brand-green
  selected labels/icons, muted unselected — matching the mockup's tabbar.

### Soft gradient background
- Add a reusable `CuteBackground` widget (e.g. `lib/app/widgets/cute_background.dart`): a `DecoratedBox`
  filling the screen with cream `#FFF7EF` plus the three soft radial-gradient blobs (use stacked
  `RadialGradient`s or a `CustomPaint`). Wrap the navigation shell's body with it so all tabs sit on
  the warm backdrop (scaffold is transparent).

### Candy-shadow primitives — `lib/app/widgets/candy.dart`
The signature look is a **hard offset shadow with zero blur** (`box-shadow: 0 5px 0 <color>`), which
Material elevation (blurred) can't express. Provide small reusable pieces callers will lean on:
- A helper `candyShadow(Color color, {double dy = 5})` → `List<BoxShadow>`
  (`BoxShadow(color: color, offset: Offset(0, dy), blurRadius: 0)`).
- `CandyButton({required label, onPressed, variant})` — pill button with a peach or green gradient
  fill + matching candy shadow + white w800 text (the mockup's 开始这一格 / 再安排下一个 buttons).
- (Optional) a `CandyCard`/`CandyContainer` wrapper applying rounded corners + a border + candy shadow,
  to keep task-15 call sites short.

### Apply to the shell now — `lib/app/navigation_shell.dart`
- Wrap the `Scaffold` body in `CuteBackground`; make the `Scaffold` transparent.
- Restyle the existing shell `AppBar` (added in task 10) to the cute brand bar: left-aligned
  "Nudge 🌱" brand wordmark in matcha green w900, the ⚙️ entry as the soft round button on the right.
- The `NavigationBar` picks up `navigationBarTheme` automatically; verify the pill + colors match.

## Out of scope
- Per-screen content (chat bubbles, capsule, composer chips, stats hero/streak/bars/ledger,
  check-in card, settings rows) → **task 15** (they'll inherit the theme but get their bespoke cute
  styling there).
- The 团团 mascot character art (still emoji from task 09) → **task 16**.
- No dark theme, no animation work, no layout/IA changes — purely the visual skin foundation.

## Acceptance criteria
- [ ] App launches on the cream gradient background; stock Material teal/purple is gone.
- [ ] Text renders in the rounded face for **both** English and Chinese (verify zh via the task-10
      language override).
- [ ] The shell shows the "Nudge 🌱" brand bar + ⚙️, and the bottom tab bar uses the mint pill +
      brand-green active state.
- [ ] `candyShadow`/`CandyButton` exist and render the hard 0-blur offset shadow (no Material blur).
- [ ] Reasonable contrast/legibility (text brown on cream, white on gradients).
- [ ] `dart format .` / `flutter analyze` / `flutter test` all clean (existing widget tests still pass;
      update any that assert on the old theme, but do not weaken them).

## Notes / hints
- Keep ALL color/shape decisions in the theme + `CuteColors` + `candy.dart`, so task 15/16 never
  hard-code a hex at a call site — same discipline that kept `app_theme.dart` the single chokepoint.
- `google_fonts` fetches at runtime on first use (then caches); that's expected. Don't bundle .ttf.
- Reference the mockup CSS directly for exact values — the palette table above is lifted from it.
- This is "skin only": if a change requires moving widgets around, it probably belongs in task 15.
