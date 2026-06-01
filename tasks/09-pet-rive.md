# 09 — 团团 mascot: PetRenderer seam + mood widget (Rive art deferred)

- **Status:** PLANNED (provisional — finalized to READY right before dispatch)
- **Owner:** Codex, or Claude if Codex is low on budget (Codex reviews)
- **Blocked by:** 06 (needs the stats/mood data)
- **Allowed new deps:** none — the real Rive `.riv` art swap is a separate, human/designer-gated
  follow-up (see "out"). Codex can't reliably author a `.riv` binary, so this task ships a
  code-only mascot.

## Goal
Give 团团 a real presence and a **mood** (happy / neutral / sad) without depending on a binary art
asset Codex can't produce. Build the `PetRenderer` seam + a code-drawn/emoji mascot widget + the
pure mood-derivation logic. A polished Rive `.riv` is swapped in later behind the same seam.

## Architecture (locked)
- `PetMood { happy, neutral, sad }` and the pure mood function live in `lib/features/pet/` — NOT in
  `lib/domain` (domain stays Flutter-free and is about persistence/plans, not UI mood).
- `PetView({required PetMood mood, double size})` is the seam: every caller just asks for "a mascot
  at mood X". Today it renders emoji/`CustomPaint`; a later task replaces its internals with Rive —
  callers don't change.

## Mood rule (locked — gentle by design, never punishes low completion)
Derive from task 06's stats. Reward *planning*, not perfection (matches the zero-shame design):
- **sad** only on disengagement: no plans at all this week.
- **happy** when actively engaged: streak ≥ 3 days, OR (any plans this week AND completion ≥ 60%).
- **neutral** otherwise.
Put this rule in a comment; thresholds are tunable.

## Scope
- in:
  - `PetMood` enum + `petMoodFromStats(...)` pure function (unit-tested for each branch).
  - `PetView` widget rendering the three moods with emoji/`CustomPaint` (no Rive).
  - Use it in the chat AI-bubble avatar (replacing the bare 🌱) and the stats mood header.
- out:
  - **No `.riv` asset and no `rive` dependency** — the real animated 团团 is a later task (needs a
    designer-made `.riv`; tracked under "Later" in the roadmap).
  - No customization (换色/配饰), no 养成/unlocks, no moods beyond the three.

## Acceptance criteria
- [ ] `PetView` renders distinct happy/neutral/sad mascots; used in chat + stats.
- [ ] `petMoodFromStats` is a pure function with unit tests for sad/neutral/happy branches.
- [ ] Domain has no Flutter import added; `PetMood` lives in the pet feature, not domain.
- [ ] `dart format` / `flutter analyze` / `flutter test` all clean.

## Notes / hints
- This is the `PetRenderer` seam (tech-design §3/§6) kept honest: swap-in Rive later, no caller churn.
