# 16 — 团团 character art (CustomPaint mascot behind the PetView seam)

- **Status:** DONE (PR #17)
- **Owner:** Codex, or Claude if Codex is low on budget (Codex reviews)
- **Blocked by:** 09 (the `PetView` seam) — DONE. (Independent of 14/15, but visually completes them.)
- **Allowed new deps:** none — drawn with `CustomPaint`, no asset, no `rive`.

## Goal
Replace the placeholder emoji inside `PetView` (task 09) with the real 团团 character from
`docs/mockups/cute.html` — a green sprout "blob" with a leaf, eyes, cheeks, and a mouth that changes
with mood. This is the seam paying off: **only `PetView`'s internals change; no caller is touched**
(chat avatar + stats header keep calling `PetView(mood:, size:)`). A polished animated Rive `.riv`
remains a separate, designer-gated "Later" task behind the same seam.

## Scope (locked against the merged code)
- **Only `lib/features/pet/pet_view.dart`** changes. Keep the constructor EXACTLY as task 09 defined
  it: `const PetView({required this.mood, this.size = 24, super.key})`. The two call sites stay
  byte-for-byte untouched: `chat_screen.dart:159` (`size: 22`) and `stats_screen.dart:76` (`size: 48`).
  `PetMood { happy, neutral, sad }` lives in `lib/features/pet/pet_mood.dart` — don't change it.
- Replace the current emoji `Text` + circular `DecoratedBox` body (and the `_PetColors`/`_emojiForMood`
  helpers) with a `CustomPaint` that draws the blob per the mockup's `.blob` CSS:
  - **Body:** rounded green blob, vertical gradient `#B8E6C4` (top) → `#8AD6A3` (bottom) — the
    mockup's `.blob` fill, slightly lighter than the button green. Hard 0-blur bottom shadow `#6CC488`
    (the mockup's `box-shadow:0 6px 0 #6cc488`) + a soft inner top-light. Blob silhouette ≈ the CSS
    `border-radius:50% 50% 48% 48% / 55% 55% 45% 45%` (rounder top, slightly tapered bottom) — a
    `Path` with rounded corners or an oval nudged to that proportion is fine.
  - **Colors:** pull matcha greens from `CuteColors` (`lib/app/cute_palette.dart`, task 14) where they
    match — `matchaGradientTop` `#8AD6A3`, `matchaGradientBottom` `#5CC78F`. The blob-specific tints
    above (`#B8E6C4`, `#6CC488`) aren't in `CuteColors`; add them as private consts in this file (don't
    pollute the shared palette for one widget). Cheek `#FF9B8A`, eye/mouth ink `#3A4A3F`.
  - **A leaf sprout** at the top (drawn, slightly rotated — the mockup's `.leaf`).
  - **Two eyes, two pink cheeks (≈0.6 opacity), and a mouth.**
  - **Mood drives the face** (`PetMood`):
    - happy — bright eyes with a tiny white highlight, upturned (smile) mouth, optional ✨ sparkle.
    - neutral — calm eyes, small flat/soft mouth.
    - sad — droopy/downcast eyes + frown, a wilted feel (the mockup uses 🥀 for sad — match that mood).
  - Everything **scales with `size`** — paint relative to the canvas (`size.width/height`), no
    hard-coded px, no overflow/clipping at either 22 or 48.

## Out of scope
- No animation (idle bounce, blink) — static per-mood art is enough here; animation rides in with the
  later Rive task.
- No new moods, no customization (换色/配饰 — that's the `PetConfigs` "Later" item).
- No caller changes (chat/stats must keep compiling untouched).

## Acceptance criteria
- [ ] `PetView` renders the drawn 团团 (not an emoji) in three clearly distinct moods.
- [ ] Crisp at both 22 (chat avatar) and 48 (stats header) — no overflow/clipping; everything
      `size`-relative.
- [ ] `PetView`'s public API is unchanged; `chat_screen.dart` and `stats_screen.dart` are NOT modified
      (`git diff` touches only `pet_view.dart` + a new test).
- [ ] A smoke `testWidgets` pumps `PetView` for each of the three moods without error (golden optional;
      if you add goldens, commit the PNGs). Existing `test/features/pet/pet_mood_test.dart` still passes.
- [ ] `dart format .` / `flutter analyze` / `flutter test` all clean.

## Notes / hints
- This is exactly what the seam was for (tech-design §3/§6): the emoji was always a placeholder
  (task 09), and swapping it here proves callers don't churn.
- `CustomPainter` is fine and dependency-free; keep the paint code readable and the mood differences
  obvious. Match the mockup's `.blob` proportions (`border-radius:50% 50% 48% 48%/55% 55% 45% 45%`).
- Device-verify the three moods after (see `docs/device-verify.md`): no plans → sad, a checked-in
  block → happy.
