import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nudge/l10n/generated/app_localizations.dart';

import '../../app/cute_palette.dart';
import '../../app/widgets/candy.dart';
import '../../domain/plan.dart';
import '../pet/pet_mood.dart';
import '../pet/pet_view.dart';
import 'stats_providers.dart';
import 'stats_summary.dart';
import 'widgets/stats_line_chart.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  StatsRange _range = StatsRange.month;

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(statsPlansProvider);
    final now = ref.watch(statsNowProvider);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: plansAsync.when(
          data: (plans) => _StatsContent(
            plans: plans,
            now: now,
            range: _range,
            onRangeChanged: (r) => setState(() => _range = r),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              Center(child: Text(localizations.statsLoadError)),
        ),
      ),
    );
  }
}

class _StatsContent extends StatelessWidget {
  const _StatsContent({
    required this.plans,
    required this.now,
    required this.range,
    required this.onRangeChanged,
  });

  final List<Plan> plans;
  final DateTime now;
  final StatsRange range;
  final ValueChanged<StatsRange> onRangeChanged;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final summary = aggregateStats(plans, now);
    final series = buildStatsSeries(plans, range, now);
    final mood = petMoodFromStats(
      plannedMinutes: summary.plannedMinutes,
      completionRate: summary.completionRate,
      streakDays: summary.streakDays,
    );

    String dateLabel(DateTime d) {
      if (range == StatsRange.fiveYears || range == StatsRange.all) {
        return '${d.year}/${d.month}';
      }
      return '${d.month}/${d.day}';
    }

    final maxHours = series.fold<double>(
      0,
      (m, p) => p.plannedHours > m ? p.plannedHours : m,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.statsScreenTitle,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      localizations.statsScreenSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              PetView(mood: mood, size: 48),
            ],
          ),
          const SizedBox(height: 20),
          _PlannedHoursHero(summary: summary),
          const SizedBox(height: 20),
          _RangeSelector(range: range, onChanged: onRangeChanged),
          const SizedBox(height: 16),
          StatsLineChart(
            title: localizations.statsHoursChartTitle,
            points: series,
            valueOf: (p) => p.plannedHours,
            yMax: maxHours < 1 ? 1 : maxHours,
            valueLabel: (p) => localizations.statsPlannedHoursValue(
              p.plannedHours.toStringAsFixed(1),
            ),
            dateLabel: dateLabel,
            emptyLabel: localizations.statsChartEmpty,
          ),
          const SizedBox(height: 16),
          StatsLineChart(
            title: localizations.statsCompletionRateTitle,
            points: series,
            valueOf: (p) => p.completionRate,
            yMax: 1,
            valueLabel: (p) => p.completionRate == null
                ? '—'
                : localizations.statsCompletionPercent(
                    (p.completionRate! * 100).round(),
                  ),
            dateLabel: dateLabel,
            emptyLabel: localizations.statsChartEmpty,
          ),
          const SizedBox(height: 20),
          _TodayLedger(plans: summary.todaysPlans),
        ],
      ),
    );
  }
}

/// Stock-style range pills; selected = peach gradient + candy shadow.
class _RangeSelector extends StatelessWidget {
  const _RangeSelector({required this.range, required this.onChanged});

  final StatsRange range;
  final ValueChanged<StatsRange> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = <StatsRange, String>{
      StatsRange.week: l10n.statsRangeWeek,
      StatsRange.month: l10n.statsRangeMonth,
      StatsRange.ytd: l10n.statsRangeYtd,
      StatsRange.fiveYears: l10n.statsRangeFiveYears,
      StatsRange.all: l10n.statsRangeAll,
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final entry in labels.entries)
          _RangePill(
            label: entry.value,
            selected: entry.key == range,
            onTap: () => onChanged(entry.key),
          ),
      ],
    );
  }
}

class _RangePill extends StatelessWidget {
  const _RangePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: selected ? null : CuteColors.white,
            gradient: selected ? CuteColors.peachGradient : null,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? CuteColors.peachGradientBottom
                  : CuteColors.borderPeach,
              width: 2,
            ),
            boxShadow: selected
                ? candyShadow(CuteColors.peachCandyShadow, dy: 3)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: selected ? CuteColors.white : CuteColors.chipBrown,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlannedHoursHero extends StatelessWidget {
  const _PlannedHoursHero({required this.summary});

  final StatsSummary summary;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: CuteColors.matchaGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: candyShadow(CuteColors.matchaCandyShadow, dy: 8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.statsPlannedHoursLabel,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: CuteColors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localizations.statsPlannedHoursValue(
                        summary.plannedHours.toStringAsFixed(1),
                      ),
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: CuteColors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              _StreakChip(days: summary.streakDays),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            localizations.statsPlannedHoursCaption,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: CuteColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Sits on the green hero, so it's the mockup's white hero pill (🔥 + amber
    // text), not the standalone amber streak row (our layout has no such row).
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: CuteColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            localizations.statsStreakValue(days),
            style: theme.textTheme.labelLarge?.copyWith(
              color: CuteColors.streakText,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayLedger extends StatelessWidget {
  const _TodayLedger({required this.plans});

  final List<Plan> plans;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.statsTodayLedgerTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            color: CuteColors.textMuted2,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        if (plans.isEmpty)
          Text(
            localizations.statsTodayLedgerEmpty,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: CuteColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          )
        else
          CandyCard(
            color: CuteColors.white,
            padding: EdgeInsets.zero,
            radius: 20,
            child: Column(
              children: [
                for (final (index, plan) in plans.indexed)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      border: index == plans.length - 1
                          ? null
                          : const Border(
                              bottom: BorderSide(
                                color: CuteColors.rowDivider,
                                width: 2,
                              ),
                            ),
                    ),
                    child: _LedgerRow(plan: plan),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({required this.plan});

  final Plan plan;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final time = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(plan.startAt));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              time,
              style: theme.textTheme.labelMedium?.copyWith(
                color: CuteColors.textFaint2,
              ),
            ),
          ),
          Expanded(
            child: Text(
              plan.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: CuteColors.textBrown,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            localizations.durationChipLabel(plan.durationMin),
            style: theme.textTheme.labelMedium?.copyWith(
              color: CuteColors.textFaint2,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${_statusEmoji(plan.status)} ${_statusLabel(localizations, plan.status)}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: CuteColors.textBrown,
            ),
          ),
        ],
      ),
    );
  }

  String _statusEmoji(PlanStatus status) {
    return switch (status) {
      PlanStatus.done => '✅',
      PlanStatus.partial => '🍃',
      PlanStatus.missed => '😴',
      PlanStatus.running => '⏳',
      PlanStatus.abandoned => '↩',
    };
  }

  String _statusLabel(AppLocalizations localizations, PlanStatus status) {
    return switch (status) {
      PlanStatus.done => localizations.statsStatusDone,
      PlanStatus.partial => localizations.statsStatusPartial,
      PlanStatus.missed => localizations.statsStatusMissed,
      PlanStatus.running => localizations.statsStatusRunning,
      PlanStatus.abandoned => localizations.statsStatusAbandoned,
    };
  }
}
