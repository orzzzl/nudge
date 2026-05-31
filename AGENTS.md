# AGENTS.md — Working agreement for the Codex implementer

This file is read by the **Codex** coding agent. It defines how to work in this repo.
Claude (the architect) owns architecture and review; you (Codex) own implementation.

## Your role

You implement well-scoped task specs from `tasks/`. You do **not** make architectural
decisions, add dependencies, or change public interfaces on your own — if a task seems to
require that, stop and leave a note in the PR instead of guessing.

## Workflow

1. Pick the task file in `tasks/` whose status is `READY` (see `tasks/README.md`).
2. Create a branch: `task/<id>-<short-slug>` (e.g. `task/03-plan-drift-schema`).
3. Implement **only what the task spec asks**. Keep the diff minimal and focused.
4. Run the checks in "Definition of done" below. They must pass.
5. Open a PR. In the description, link the task file and fill the PR checklist.
6. Claude reviews. Address review comments on the same branch. Do not merge yourself.

## Hard rules (do not violate)

- **Comments and identifiers in English.** User-facing strings go through i18n (ARB), never
  hard-coded. No Chinese in code except inside `*.arb` translation files.
- **Respect the architecture seams.** Depend on interfaces in `lib/domain`, never on concrete
  implementations across layers. The four seams are sacred:
  `PlanRepository`, `IntentParser`, `Notifier`, `PetRenderer`.
- **No new dependencies** without an explicit OK written in the task spec.
- **No network, no account, no analytics SDK** in the MVP. Local-first only.
- **No Google Play Services hard dependency** — must build for the China market.
- Keep functions small; match the style of surrounding code; no dead code or commented-out blocks.

## Definition of done (every PR)

- [ ] `dart format .` produces no changes
- [ ] `flutter analyze` reports no errors or new warnings
- [ ] `flutter test` passes (add/adjust tests for the code you touched)
- [ ] The task's own acceptance criteria are all met
- [ ] No hard-coded user-facing strings; no Chinese outside `*.arb`
- [ ] Diff is scoped to the task; no drive-by refactors

## When in doubt

Stop and write your question in the PR description (or as a `// TODO(claude): ...` comment)
rather than inventing behavior. A small, correct, scoped PR beats a large speculative one.
