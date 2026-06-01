# tasks/ — specs Claude writes for Codex

Each `NN-slug.md` is one self-contained, reviewable unit of work. Codex implements `READY` ones.

> **Why the backlog below has no `.md` files yet:** specs are written *just before* a task is
> dispatched, so each one reflects the interfaces that actually landed before it (e.g. task 05's
> spec could rely on task 04's `PlanRepository`). The roadmap here is the full known plan; a
> `PLANNED` row becomes a real `NN-slug.md` spec the moment we're about to start it.

## Status legend

- `PLANNED` — on the roadmap, scope known, spec not written yet.
- `DRAFT` — Claude still writing the spec; do not start.
- `READY` — fully specified; Codex may pick it up.
- `IN_PROGRESS` — a branch exists, work underway.
- `IN_REVIEW` — PR open, awaiting review.
- `BLOCKED` — waiting on another task or a human decision (see `Blocked by`).
- `DONE` — merged to `main`.

## Done & in flight

| # | Task | Status | Blocked by |
|---|------|--------|------------|
| 01 | [Flutter project scaffold](01-flutter-scaffold.md) | DONE | — |
| 02 | [Drift DB + Plans schema](02-drift-plans-schema.md) | DONE | — |
| 03 | [Bilingual i18n: add Chinese (zh)](03-i18n-zh.md) | DONE | — |
| 04 | [Domain: Plan entity + PlanRepository](04-domain-plan-repository.md) | DONE | — |
| 05 | [Build-plan + check-in core loop (chat UI)](05-build-plan-checkin-ui.md) | DONE | — |
| 06 | [乖乖图 / Stats tab](06-stats-guai-chart.md) | DONE | — |
| 12 | [CI (GitHub Actions)](12-ci-github-actions.md) | DONE | — |
| 11 | [Active-plan persistence](11-active-plan-persistence.md) | DONE | — |
| 07 | [Local notifications (reminder seam)](07-local-notifications.md) | DONE | — |
| 08 | [Auto check-in at time-up](08-auto-checkin-timeup.md) | DONE | — |
| 10 | [Settings + 勿扰](10-settings-dnd.md) | DONE | — |
| 09 | [团团 mascot + PetRenderer seam](09-pet-rive.md) | READY | — |

## Backlog — planned MVP tasks

Scope is known; the `.md` spec gets written right before dispatch (PLANNED → READY). Numbers are
stable IDs — the rows below are in **recommended run order** (Codex-reviewed), not numeric order.

**Remaining order:** 09 — the last MVP task, now READY + dispatched (06/07/08/10/11/12 done). Key
constraint: **09 after 06** (mood is derived from the stats). Once 09 merges, the MVP feature set is
complete; only "Later" follow-ups remain.

## Later — post-MVP, not yet scoped

- Real animated 团团 `.riv` art — swap it in behind the task-09 `PetRenderer` seam. Needs a
  designer-made Rive asset (Codex can't author a `.riv` binary), so it's gated on art, not code.
- Multi-week streak — task 06's streak caps at the current week (single-week query). Compute it
  over a wider window so a run spanning the Monday boundary still counts. Small, isolated.
- On-device DB smoke test — host unit tests + CI run on the dev machine's sqlite3, so they can't
  catch native-lib problems (e.g. the `sqlite3_flutter_libs` 0.6.0+eol crash fixed in PR #9). Add an
  `integration_test` that opens the real DB on an emulator in CI, or at least a documented
  "run on a device after DB-touching changes" check.
- Notification permission re-check — task 07's `_requestPermissions` caches its result, so denying
  notifications once skips all reminders for the session even if granted later in settings. Only
  cache a granted result (re-check when not granted). Small polish.
- Pet customization (换色 / 配饰) — the `PetConfigs` table already exists for this.
- Re-engagement nudges ("3h with no plan", morning prompt) — needs 07; must stay non-naggy.
- Cloud sync + accounts (China/US region-split), app-store release prep, optional LLM intent parsing.

> Tracked outside tasks/: [issue #2](../../issues/2) — ✅ verified & closed: scaffold runs on a
> real Android emulator (API 36) and iOS simulator (26.5); bundle-id rename confirmed native.

## Task template

```markdown
# NN — <title>

- **Status:** DRAFT | READY | IN_PROGRESS | BLOCKED | DONE
- **Owner:** Codex
- **Blocked by:** <task # or "—">
- **Allowed new deps:** <explicit list, or "none">

## Goal
<one paragraph: what and why>

## Scope
- in: <bullet list of exactly what to do>
- out: <explicitly what NOT to touch>

## Acceptance criteria
- [ ] <verifiable outcome 1>
- [ ] <verifiable outcome 2>

## Notes / hints
<file paths, interface names, gotchas>
```
