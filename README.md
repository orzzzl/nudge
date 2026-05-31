# Nudge · 下一格

> A near-zero-friction self-discipline app for lazy people.
> Every two hours it asks one question — *"what's the next block?"* — then later asks if you did it.
> 给懒人的零负担自律 App：每两小时问你一句"接下来这一格做什么"，到点再问你做没做。

**English name:** Nudge **·** **中文名:** 下一格

---

## What it is

Two tabs, nothing else:

1. **聊天 (Chat)** — tell it what you'll do for the next block; pick a duration; get a local
   reminder when time's up; tap ✅ / 🍃 / 😴 to check in. A pet, **团团**, talks to you.
2. **乖乖图 (Stats)** — see how "good" you've been: planned hours, completion rate, streak.

## Status — MVP (local-first)

- **Local-only.** No account, no server, no remote push, no LLM. Everything lives on-device.
- Cloud sync, app-store release, and AI parsing are **future phases** — the architecture leaves
  seams for them (see [docs/tech-design.md](docs/tech-design.md)).

## Tech stack (planned)

| Concern | Choice |
|---|---|
| Cross-platform | Flutter (Dart) — one codebase for iOS + Android |
| State management | Riverpod |
| Local database | Drift (SQLite) |
| Pet animation | Rive |
| Reminders | flutter_local_notifications (on-device scheduling) |
| i18n | gen_l10n + ARB (zh / en) |

Full rationale: **[docs/tech-design.md](docs/tech-design.md)**.

## Markets

Designed for **China + US** from day one: code comments in English, UI bilingual (zh/en),
no hard dependency on Google Play Services. See the dual-market analysis in the tech design.

## Repo layout

```
docs/
  tech-design.md      # architecture & tech choices
  workflow.md         # how Claude (architect) and Codex (implementer) collaborate
  mockups/            # clickable HTML design mockups (open in a browser)
tasks/                # task specs Claude writes for Codex to pick up
AGENTS.md             # working agreement for the Codex coding agent
```

## Collaboration model

This repo is built by two AI agents with a human in the loop:

- **Claude (architect)** — owns architecture, interfaces, and review; writes task specs in `tasks/`.
- **Codex (implementer)** — picks up tasks, opens PRs; Claude reviews before merge.

See **[docs/workflow.md](docs/workflow.md)** and **[AGENTS.md](AGENTS.md)**.
