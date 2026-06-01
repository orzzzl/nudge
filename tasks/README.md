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

## Backlog — planned MVP tasks

Scope is known; the `.md` spec gets written right before dispatch. Rough order, not locked.

| # | Task | What it adds | Depends on |
|---|------|--------------|------------|
| 06 | [乖乖图 / Stats](06-stats-guai-chart.md) | Reactive aggregation over `PlanRepository` (planned hours, completion rate, streak) + the stats-tab UI. The "hero metric" is **planned time**, not completion %. | 04 |
| 07 | [Local notifications (`Notifier` seam)](07-local-notifications.md) | Schedule an on-device notification at a plan's `endAt`; tapping it deep-links to check-in. Android exact-alarm + iOS + timezone. No remote/push (post-MVP). | 05 |
| 08 | [Auto check-in at time-up](08-auto-checkin-timeup.md) | When the countdown hits 0 (in-app and via the notification), surface the check-in sheet automatically, not only on the capsule button. | 07 |
| 09 | [团团 mascot with Rive (`PetRenderer` seam)](09-pet-rive.md) | Replace the 🌱 emoji with the Rive state-machine character; mood (happy/neutral/sad) driven by recent completion. | 05 |
| 10 | [Settings + 勿扰](10-settings-dnd.md) | The ⚙️/🌙 entry: do-not-disturb toggle, manual language override, basic about. | 05 |
| 11 | [Active-plan persistence](11-active-plan-persistence.md) | On launch, restore the running plan (capsule / prompt check-in) instead of losing it — today it lives only in in-memory `ChatController` state. | 04 |
| 12 | [CI (GitHub Actions)](12-ci-github-actions.md) | Run `dart format --set-exit-if-changed`, `flutter analyze`, `flutter test` on every PR so `main` stays green without manual local checks. | — |

## Later — post-MVP, not yet scoped

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
