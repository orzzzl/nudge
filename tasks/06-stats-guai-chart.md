# 06 — 乖乖图 / Stats tab

- **Status:** PLANNED (provisional — finalized to READY right before dispatch)
- **Owner:** Codex, or Claude if Codex is low on budget (Codex reviews)
- **Blocked by:** — (builds on task 04 `PlanRepository`; task 05 produces the data)
- **Allowed new deps:** none (hand-draw the bar chart; no charting library)

## Goal
Fill the Stats tab with the "how good have I been" view, computed **reactively** from
`PlanRepository`. Per tech-design §6 the **hero metric is planned time, not completion %** — we
reward showing up to plan, not perfection.

## Scope
- in:
  - A pure aggregation function + a Riverpod provider that, from `watchPlansInRange` over the
    current week (and today), derives:
    - **planned minutes** total (Σ `durationMin`) — the hero number, shown as hours.
    - **completion rate** = (done×1 + partial×0.5) ÷ (checked-in count), as a %.
    - **streak** = consecutive days ending today with ≥1 plan.
    - **per-day planned minutes** for the 7 weekday bars.
    - **today's plans** list (the ledger), each with its status.
  - Stats screen UI: hero hours + warm caption, a 🔥 streak chip, a hand-drawn 7-day bar chart,
    a secondary completion-rate bar, and today's ledger (time · title · duration · status emoji).
  - i18n: all strings in `app_en.arb` + `app_zh.arb`.
  - Tests: the aggregation over an in-memory repo — planned total, completion rate (partial = 0.5),
    streak, per-day buckets, ledger.
- out:
  - No date-range picker / month view; no charting dependency; no editing/deleting plans.
  - Don't change the domain/DAO. (A read-only convenience query on the repo is OK if needed.)

## Acceptance criteria (draft)
- [ ] Hero shows planned **hours** (not completion %); completion rate counts partial as 0.5.
- [ ] Streak counts consecutive days (ending today) with ≥1 plan.
- [ ] Weekly bar chart renders 7 days from real data; ledger lists today's plans with status.
- [ ] Updates reactively as plans are created/checked in.
- [ ] New strings in both ARBs; no Chinese outside `*.arb`.
- [ ] `dart format` / `flutter analyze` / `flutter test` all clean.

## Notes / hints
- Keep aggregation a **pure function** of `List<Plan>` so it is trivially testable.
- Framing matters: caption around "认真度过的时间", not a guilt-inducing completion score.
