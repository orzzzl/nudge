# tasks/ — specs Claude writes for Codex

Each `NN-slug.md` is one self-contained, reviewable unit of work. Codex implements `READY` ones.

## Status legend

- `DRAFT` — Claude still writing it; do not start.
- `READY` — fully specified; Codex may pick it up.
- `IN_PROGRESS` — a branch/PR exists.
- `BLOCKED` — waiting on another task or a human decision (see `Blocked by`).
- `DONE` — merged to `main`.

## Index

| # | Task | Status | Blocked by |
|---|------|--------|------------|
| 01 | [Flutter project scaffold](01-flutter-scaffold.md) | DONE | — |
| 02 | [Drift DB + Plans schema](02-drift-plans-schema.md) | READY | — |
| 03 | [Bilingual i18n: add Chinese (zh)](03-i18n-zh.md) | READY | — |

> Tracked outside tasks/: [issue #2](../../issues/2) — verify the task-01 scaffold runs on real
> iOS + Android devices (verification action, no code change).

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
