# 09 — 团团 mascot: PetRenderer seam + mood widget (Rive art deferred)

- **Status:** DONE
- **Owner:** Codex, or Claude if Codex is low on budget (Codex reviews)
- **Blocked by:** 06 (needs the stats/mood data) — DONE
- **Allowed new deps:** none — the real Rive `.riv` art swap is a separate, human/designer-gated
  follow-up (see "out"). Codex can't reliably author a `.riv` binary, so this task ships a
  code-only mascot.

## Goal
Give 团团 a real presence and a **mood** (happy / neutral / sad) without depending on a binary art
asset Codex can't produce. Build the `PetRenderer` seam + a code-drawn/emoji mascot widget + the
pure mood-derivation logic. A polished Rive `.riv` is swapped in later behind the same seam.

## Architecture (locked against the real interfaces)
New feature folder `lib/features/pet/`. Domain stays Flutter-free — `PetMood` is UI, so it lives in
the pet feature, NOT in `lib/domain/`.

### `lib/features/pet/pet_mood.dart` — enum + pure rule
- `enum PetMood { happy, neutral, sad }`.
- Pure function taking **primitives** (keeps it dependency-light + trivially testable; do NOT take a
  `StatsSummary` here):
  ```dart
  PetMood petMoodFromStats({
    required int plannedMinutes,   // StatsSummary.plannedMinutes for the week
    required double completionRate, // StatsSummary.completionRate (0..1)
    required int streakDays,        // StatsSummary.streakDays
  })
  ```
- **Mood rule (locked — gentle by design, never punishes low completion). Put the rule + thresholds
  in a comment marked tunable.** Evaluate in this order:
  - **sad** only on disengagement: `plannedMinutes == 0` (no plans at all this week).
  - **happy** when actively engaged: `streakDays >= 3 || (plannedMinutes > 0 && completionRate >= 0.60)`.
  - **neutral** otherwise.

### `lib/features/pet/pet_view.dart` — the seam
- `PetView({required PetMood mood, double size = 24})` — a `StatelessWidget`. Every caller just asks
  for "a mascot at mood X". Today it renders emoji (or `CustomPaint`) per mood; a later task replaces
  its internals with Rive and **callers do not change**. Render three visually distinct moods
  (suggestion, Codex may refine: happy 🌳 / neutral 🌱 / sad 🥀 — or one emoji with a mood-tinted
  backdrop). Keep it self-contained, no external asset.

### `lib/features/pet/pet_providers.dart` — chat-side mood
- `petMoodProvider` → `Provider<PetMood>` that reads `statsSummaryProvider`
  (`lib/features/stats/stats_providers.dart`, an `AsyncValue<StatsSummary>`) and maps to a mood via
  `petMoodFromStats`, defaulting to `PetMood.neutral` on loading/error
  (`.maybeWhen(data: ..., orElse: () => PetMood.neutral)`). This gives chat callers a plain `PetMood`.

## Callers (locked)
- **Chat avatar** — `lib/features/chat/chat_screen.dart`, `_MessageBubble`: replace the bare
  `const Text('🌱', style: TextStyle(fontSize: 22))` (the `if (!isUser) ...[ ]` avatar) with
  `PetView(mood: mood, size: 22)`. `_MessageBubble` is a `StatelessWidget` — add a `required PetMood mood`
  field; `_ChatScreenState.build` already has `ref` (it's a `ConsumerState`), so
  `ref.watch(petMoodProvider)` there and pass `mood: mood` into each `_MessageBubble`.
- **Stats mood header** — `lib/features/stats/stats_screen.dart`, `_StatsContent` (a `StatelessWidget`
  that already holds the full `summary`): add a `PetView` to the header near `statsScreenTitle`,
  deriving mood **inline** from the summary it already has
  (`petMoodFromStats(plannedMinutes: summary.plannedMinutes, completionRate: summary.completionRate,
  streakDays: summary.streakDays)`) — no provider needed on this side. Use a larger `size` (e.g. 48).

## Out of scope
- **No `.riv` asset and no `rive` dependency** — the real animated 团团 is a later task (needs a
  designer-made `.riv`; already tracked under "Later" in `tasks/README.md`).
- No customization (换色/配饰), no 养成/unlocks, no moods beyond the three. No new i18n strings
  (the mascot is non-textual; if a semantics label is wanted, that's optional polish, not required).

## Acceptance criteria
- [ ] `petMoodFromStats` is a pure function with unit tests covering every branch: sad
      (`plannedMinutes == 0`), happy via `streakDays >= 3`, happy via `plannedMinutes > 0 &&
      completionRate >= 0.60` (incl. the `== 0.60` boundary), and neutral otherwise (e.g.
      `plannedMinutes > 0`, `completionRate < 0.60`, `streakDays < 3`).
- [ ] `PetView` renders distinct happy/neutral/sad mascots and is used in BOTH the chat avatar and
      the stats header.
- [ ] No Flutter import added under `lib/domain/`; `PetMood` lives in `lib/features/pet/`.
- [ ] The existing chat/stats widget tests still pass (the avatar swap must not break them).
- [ ] `dart format .` / `flutter analyze` / `flutter test` all clean.

## Notes / hints
- This is the `PetRenderer` seam (tech-design §3/§6) kept honest: swap-in Rive later, no caller churn.
- `_ChatScreenState` became a `ConsumerStatefulWidget` in task 08 — reuse its `ref` for `petMoodProvider`;
  don't convert `_MessageBubble` into a Consumer (pass the mood down instead, so the bubble stays dumb).
- Keep `PetView` tolerant of a wide `size` range (22 in chat, ~48 in stats) without overflow.
