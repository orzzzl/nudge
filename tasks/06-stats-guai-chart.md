# 06 — 乖乖图 / Stats tab

- **Status:** DONE (reviewed by Claude; merged in PR #8)
- **Owner:** Codex
- **Blocked by:** — (builds on task 04 `PlanRepository`; task 05 produces the data)
- **Allowed new deps:** none (hand-draw the bar chart; no charting library)

## Definitions (locked — don't reinterpret)
- **Week** = Monday→Sunday containing "today" (device local date). Bars are Mon..Sun.
- **A day "has a plan"** = ≥1 plan whose `startAt` falls on that local date.
- **Planned minutes** (hero) = Σ `durationMin` of all plans in the week. Display as hours, 1 decimal.
- **Checked-in plans** = plans with status `done`, `partial`, or `missed` (exclude `running` &
  `abandoned`).
- **Completion rate** = (done×1 + partial×0.5) ÷ (checked-in count), as a %; 0 checked-in → show 0%
  (or an empty state), never divide by zero.
- **Streak** = number of consecutive days, counting back from today, where each day "has a plan".
  Today with no plan yet ⇒ streak counts back from yesterday (today doesn't break a streak until
  the day ends). Keep this rule in a comment.
- **Today's ledger** = plans whose `startAt` is today, ordered by `startAt`.
- Pull the week's data with one `repo.watchPlansInRange(start: mondayMidnight, end: nextMondayMidnight)`
  and derive everything else in memory.

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
  - Don't change the domain / repository / DAO — use the existing `watchPlansInRange` ONLY.

## Acceptance criteria
- [ ] Hero shows planned **hours** (not completion %); completion rate counts partial as 0.5 and
      never divides by zero.
- [ ] Streak matches the Definitions rule (consecutive days back from today; today-with-no-plan
      doesn't break it).
- [ ] Weekly bar chart renders Mon–Sun from real data; ledger lists today's plans with status emoji.
- [ ] Updates reactively as plans are created / checked in (uses `watchPlansInRange`).
- [ ] Aggregation is a pure function of `(List<Plan>, DateTime now)` with direct unit tests for
      planned total, completion rate (incl. partial=0.5 and zero-checkin), streak, and per-day buckets.
- [ ] New strings in both `app_en.arb` and `app_zh.arb`; no Chinese outside `*.arb`.
- [ ] `dart format` / `flutter analyze` / `flutter test` all clean.

## Notes / hints
- Keep aggregation a **pure function** of `List<Plan>` so it is trivially testable.
- Framing matters: caption around "认真度过的时间", not a guilt-inducing completion score.
