# Collaboration workflow — Claude (architect) × Codex (implementer)

A human (the product owner) sets direction. Two AI agents do the building.

```
            ┌──────────── product owner (human) ────────────┐
            │ sets goals, priorities, approves merges        │
            └───────────────────────┬───────────────────────┘
                                    │
        writes architecture,        │        does the grunt work,
        interfaces, task specs       │        opens PRs
                                    ▼
   ┌─────────────┐   tasks/*.md    ┌─────────────┐   Pull Request   ┌──────────┐
   │   CLAUDE     │ ─────────────▶ │    CODEX     │ ───────────────▶ │  GitHub   │
   │ (architect)  │                │ (implementer)│                  │   PRs     │
   │              │ ◀───── review comments ──────────────────────── │           │
   └─────────────┘                └─────────────┘                  └──────────┘
        │  approves / requests changes                                   │
        └────────────────────────── merge to main ◀─────────────────────┘
```

## Division of labor

| | **Claude — architect** | **Codex — implementer** |
|---|---|---|
| Owns | Architecture, interfaces, data model, task specs, code review | Implementation of scoped tasks |
| Writes | `docs/`, `tasks/*.md`, interface stubs in `lib/domain`, ADRs | Concrete impls, widgets, tests, wiring |
| Decides | Dependencies, layer boundaries, naming conventions | Nothing architectural — asks instead |
| Reviews | Every Codex PR before merge | Responds to review comments |

**Rule of thumb:** anything that is *decomposable, well-specified, and mechanical* → Codex.
Anything requiring a *cross-cutting decision or judgment call* → Claude.

> **Budget fallback:** the product owner's token budget is limited and shared. When Codex is out
> of budget (or a task is blocking progress), **Claude also implements tasks directly** — Claude
> is not review-only. In that case Claude self-reviews against the same `AGENTS.md` checklist
> before merging. Architecture ownership doesn't change; only who types the code does.

## The loop

1. **Claude** writes a task spec in `tasks/NN-slug.md` using the template in `tasks/README.md`,
   sets status `READY`, and (when GitHub is set up) optionally mirrors it as a GitHub Issue.
2. **Codex** picks a `READY` task, branches `task/NN-slug`, implements, opens a PR linking the task.
3. **Claude** reviews the PR against the task's acceptance criteria and `AGENTS.md` hard rules:
   - correctness, scope creep, interface/layer violations, missing tests, hard-coded strings.
   - leaves inline comments; verdict = **approve** or **request changes**.
4. **Codex** addresses comments on the same branch until Claude approves.
5. **Human** (or Claude, if delegated) merges to `main`. Task status → `DONE`.

## What goes through a PR (merge-gate policy)

The PR + review gate exists to catch **code** problems (correctness, build breakage, seam/arch
violations) before they reach `main`. So:

- **Code changes → always a PR + review** (Codex's work, and Claude's when Claude implements).
- **Architect docs/specs/bookkeeping → committed directly to `main`** by Claude: `tasks/*.md`,
  `docs/`, task-status updates, `.gitignore`/policy notes, CI-less config. These have no second
  reviewer in this two-agent setup (both agents authenticate as the same GitHub account, so GitHub
  blocks self-approval anyway), can't break the build, and are trivially revertible.

Chosen by the product owner (2026-06-01). Not Google-style "every change is a reviewed CL" — docs
trade an audit gate for speed; code keeps the gate.

## Branch & PR conventions

- Branch: `task/<NN>-<slug>` for tasks; `arch/<slug>` for Claude's architecture commits.
- One task = one PR. Keep PRs small and reviewable.
- PR description must link the task file and tick the Definition-of-done checklist from `AGENTS.md`.
- `main` is always green (format + analyze + test pass).

## Device-verify

Host tests prove logic, not that the app runs on a device (native libs, notifications, real
navigation, locale switch, on-device rendering). After a DB/plugin/dep change, or to close out a
user-facing feature, run a manual pass on the emulator. The full step-by-step is in
[`docs/device-verify.md`](device-verify.md) — boot the AVD, `flutter run`, drive with
`adb input` + screenshots, and use the clock trick for the time-up/notification paths.

## What Claude reviews for

1. **Correctness** — does it meet the acceptance criteria and handle edge cases?
2. **Scope** — no changes outside the task; no drive-by refactors.
3. **Seams** — depends only on `lib/domain` interfaces; the four seams stay intact.
4. **i18n** — no hard-coded user strings; no Chinese outside `*.arb`.
5. **Tests** — meaningful coverage for the touched code.
6. **Style** — matches surrounding code; small functions; English comments.
