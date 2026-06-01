# 16 — 团团 character art (CustomPaint mascot behind the PetView seam)

- **Status:** PLANNED (finalize to READY right before dispatch)
- **Owner:** Codex, or Claude if Codex is low on budget (Codex reviews)
- **Blocked by:** 09 (the `PetView` seam) — DONE. (Independent of 14/15, but visually completes them.)
- **Allowed new deps:** none — drawn with `CustomPaint`, no asset, no `rive`.

## Goal
Replace the placeholder emoji inside `PetView` (task 09) with the real 团团 character from
`docs/mockups/cute.html` — a green sprout "blob" with a leaf, eyes, cheeks, and a mouth that changes
with mood. This is the seam paying off: **only `PetView`'s internals change; no caller is touched**
(chat avatar + stats header keep calling `PetView(mood:, size:)`). A polished animated Rive `.riv`
remains a separate, designer-gated "Later" task behind the same seam.

## Scope (locked)
- `lib/features/pet/pet_view.dart`: swap the emoji `Text` for a `CustomPaint` (or a small composed
  widget) that draws the blob per the mockup's `.blob` CSS:
  - Body: rounded green blob, gradient `#8AD6A3`→`#5CC78F` (use `CuteColors` from task 14 if present;
    otherwise local consts), with the soft bottom shadow feel.
  - A leaf 🌱-style sprout at the top.
  - Two eyes, two pink cheeks, and a mouth.
  - **Mood drives the face** (the existing `PetMood { happy, neutral, sad }`):
    - happy — bright eyes (tiny highlight), upturned mouth, optional ✨/⭐ sparkle accents.
    - neutral — calm eyes, small flat/soft mouth.
    - sad — droopy eyes/mouth, a wilted look (the mockup uses 🥀 for sad — match that downcast feel).
  - Everything **scales with `size`** (currently called at 22 in chat, ~48 in stats) with no overflow
    or clipping — paint relative to the canvas size.
- Keep `PetView`'s constructor/API exactly as task 09 defined it (`{required PetMood mood, double size}`).

## Out of scope
- No animation (idle bounce, blink) — static per-mood art is enough here; animation rides in with the
  later Rive task.
- No new moods, no customization (换色/配饰 — that's the `PetConfigs` "Later" item).
- No caller changes (chat/stats must keep compiling untouched).

## Acceptance criteria (draft — finalized at dispatch)
- [ ] `PetView` renders the drawn 团团 (not an emoji) in three clearly distinct moods.
- [ ] Crisp at both 22 (chat avatar) and ~48 (stats header) — no overflow/clipping; everything
      `size`-relative.
- [ ] `PetView`'s public API is unchanged; no caller file is modified.
- [ ] A widget/golden test (or at least a smoke `testWidgets` per mood) covers it; existing tests pass.
- [ ] `dart format .` / `flutter analyze` / `flutter test` all clean.

## Notes / hints
- This is exactly what the seam was for (tech-design §3/§6): the emoji was always a placeholder
  (task 09), and swapping it here proves callers don't churn.
- `CustomPainter` is fine and dependency-free; keep the paint code readable and the mood differences
  obvious. Match the mockup's `.blob` proportions (`border-radius:50% 50% 48% 48%/55% 55% 45% 45%`).
- Device-verify the three moods after (see `docs/device-verify.md`): no plans → sad, a checked-in
  block → happy.
