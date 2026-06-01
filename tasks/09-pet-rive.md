# 09 — 团团 mascot with Rive (the `PetRenderer` seam)

- **Status:** PLANNED (provisional — finalized to READY right before dispatch)
- **Owner:** Codex, or Claude if Codex is low on budget (Codex reviews)
- **Blocked by:** 05 (06 for mood data)
- **Allowed new deps:** rive

## Goal
Replace the 🌱 emoji placeholder with the real animated mascot **团团** — a Rive character whose
mood (happy / neutral / sad) reflects recent completion. Define the `PetRenderer` seam so future
customization (换色/配饰/养成) stays isolated.

## Scope
- in:
  - A `.riv` asset with a state machine exposing a `mood` input (happy/neutral/sad). If no designer
    asset exists, ship a minimal placeholder `.riv` and flag it for art polish.
  - `PetRenderer` widget/seam taking a mood enum and rendering 团团; used in chat AI bubbles and the
    stats mood header.
  - Mood derived from recent completion (reuse task 06's aggregation).
  - Graceful fallback (e.g. the 🌱 emoji) if the asset fails to load.
- out:
  - No customization (换色/配饰) — that's a later task. No养成/unlocks. No new moods beyond the three.

## Acceptance criteria (draft)
- [ ] 团团 renders via Rive in the chat and stats surfaces; mood changes with completion.
- [ ] Falls back gracefully if the asset is missing/unloadable.
- [ ] Asset registered in `pubspec.yaml` assets; seam keeps Rive out of feature widgets that just
      need "a mascot at mood X".
- [ ] `dart format` / `flutter analyze` / `flutter test` all clean.

## Notes / hints
- This is the `PetRenderer` seam (tech-design §3/§6) — pet config & customization build on it later.
- A real polished 团团 `.riv` likely needs a designer; a functional placeholder is acceptable here.
