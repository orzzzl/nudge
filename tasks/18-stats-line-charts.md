# 18 — 乖乖图 v2: hand-drawn line charts + range switcher (+ streak rule B)

- **Status:** IN_REVIEW (PR #22, Claude — Codex reviews)
- **Owner:** Claude (Codex reviews)
- **Blocked by:** 06 (stats), 17 (streak) — DONE.
- **Allowed new deps:** none — charts are hand-drawn with `CustomPaint` (owner's call, no `fl_chart`).

## Goal
Rework the 乖乖图 stats tab from the single-week bar + completion bar into two **stock-style line
charts** with a shared time-range switcher, and tighten the streak rule. All date math local — no UTC.

## Changes
1. **Streak → rule B** (`stats_summary.dart`): a day counts toward the streak only if it has ≥1 plan
   whose status is **not** `missed`/`abandoned` (i.e. at least one `done`/`partial`/`running`). Build
   `activeDays` from `plans.where((p) => p.status != missed && != abandoned)`. Update task 17's
   semantic note. (Was: any planned block counted.)
2. **Planned-hours chart**: replace the "计划分钟数" bar chart. Y = hours with decimals (e.g. 3.5h).
3. **Completion-rate chart (new)**: per bucket `(#done + #partial) / (#done + #partial + #missed +
   #abandoned)` — **partial counts as complete**, and **abandoned counts as a miss** (in the
   denominator, 0 score). `running` (not yet answered) is excluded. A bucket with no countable plans =
   no point (line gaps / skips it). Apply the same "abandoned = miss" rule to the existing
   `aggregateStats.completionRate` (which feeds the mascot mood): abandoned moves from excluded to a
   miss in the denominator (its partial weighting there stays 0.5 — that internal metric is unchanged
   otherwise).
4. **Both are line charts** with a **shared range switcher**: 最近一周 / 最近一月 / 今年(YTD) / 5年 /
   全部. Bucket granularity by range: week & month = daily; YTD = weekly (Mon-start); 5Y & all =
   monthly. Buckets are generated continuously across the range (empty buckets present, so the x-axis
   is continuous; planned-hours plots 0, completion gaps).
5. **Tap/drag to read a value** (stock-style): touching the chart highlights the nearest bucket and
   shows its date + value.
6. Keep the hero (本周计划时间 + streak) and the 今日 ledger.

## Design (locked against real files)
- **`stats_summary.dart`**: keep `aggregateStats` (hero/ledger/streak) but switch the streak to rule B.
  Add a pure, tested series builder:
  - `enum StatsRange { week, month, ytd, fiveYears, all }`
  - `class StatsPoint { DateTime bucketStart; double plannedHours; double? completionRate; }`
  - `List<StatsPoint> buildStatsSeries(List<Plan> plans, StatsRange range, DateTime now)` — local-time
    bucketing (`statsDayStart`/`statsWeekStart`/`DateTime(y,m)`), continuous buckets start→now.
- **Data/provider** (`stats_providers.dart`): expose the full plan list to the screen (already queried
  `watchPlansInRange(DateTime(2000), weekEnd)`); the range is screen-local state, so changing it
  recomputes `buildStatsSeries` from the already-streamed plans (no re-query). Keep
  `statsSummaryProvider` for the hero/ledger/streak.
- **`stats_screen.dart`** + a new `widgets/`:
  - `RangeSelector` — cute pill row (selected = peach gradient, candy shadow); shared, drives both charts.
  - `LineChartCard` + a `_LineChartPainter` `CustomPaint` — axis baseline + gridlines, the polyline
    (matcha gradient stroke), point dots, y-labels (hours / %), sparse x-labels per range, and a
    touch readout. Pull all color/shape from `CuteColors`/`candy.dart`; no hex at call sites.
    Reusable for both metrics via a value-accessor + y formatter; `completionRate` null ⇒ gap.

## Out of scope
- No new dependency. No change to the chat/settings/pet code. No data-model/schema change.
- Not persisting the selected range across launches (screen-local is fine for v1).

## Acceptance criteria
- [ ] Streak uses rule B (a fully-missed day no longer extends it).
- [ ] Planned-hours line chart in hours w/ decimals; completion-rate line chart (partial = complete).
- [ ] Range switcher 1周/1月/今年/5年/全部 reflows both charts with sensible bucket granularity; no
      overflow/jank at any range; empty ranges render gracefully (no data state).
- [ ] Tap/drag shows the nearest bucket's date + value.
- [ ] All date math local — no UTC, no SQL `date()`, calendar-based bucketing.
- [ ] New unit tests for `buildStatsSeries` (each range's bucketing, hours decimals, completion incl.
      partial, empty/gap buckets) + the rule-B streak; existing tests stay green.
- [ ] `dart format .` / `flutter analyze` / `flutter test` all clean; device-verified on a sim (zh).

## Notes / hints
- drift hands back local `DateTime`s; keep bucketing in Dart (see task 17).
- Daily-bucket ranges are small (≤30); YTD ≤53 weekly; 5Y = 60 monthly; all = monthly since first plan
  — all cheap to aggregate in Dart from the single all-plans stream.
