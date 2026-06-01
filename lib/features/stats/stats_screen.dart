import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nudge/l10n/generated/app_localizations.dart';

import '../../domain/plan.dart';
import 'stats_providers.dart';
import 'stats_summary.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(statsSummaryProvider);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: summary.when(
          data: (data) => _StatsContent(summary: data),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              Center(child: Text(localizations.statsLoadError)),
        ),
      ),
    );
  }
}

class _StatsContent extends StatelessWidget {
  const _StatsContent({required this.summary});

  final StatsSummary summary;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
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
          const SizedBox(height: 20),
          _PlannedHoursHero(summary: summary),
          const SizedBox(height: 20),
          _WeeklyBars(summary: summary),
          const SizedBox(height: 20),
          _CompletionBar(summary: summary),
          const SizedBox(height: 20),
          _TodayLedger(plans: summary.todaysPlans),
        ],
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
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
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localizations.statsPlannedHoursValue(
                        summary.plannedHours.toStringAsFixed(1),
                      ),
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w800,
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
              color: theme.colorScheme.onPrimaryContainer,
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥'),
          const SizedBox(width: 6),
          Text(
            localizations.statsStreakValue(days),
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyBars extends StatelessWidget {
  const _WeeklyBars({required this.summary});

  final StatsSummary summary;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final maxMinutes = summary.maxDailyPlannedMinutes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.statsWeeklyChartTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final (index, day) in summary.dailyPlannedMinutes.indexed)
                Expanded(
                  child: _DayBar(
                    label: _weekdayLabel(localizations, index),
                    plannedMinutes: day.plannedMinutes,
                    maxMinutes: maxMinutes,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _weekdayLabel(AppLocalizations localizations, int index) {
    return switch (index) {
      0 => localizations.statsWeekdayMon,
      1 => localizations.statsWeekdayTue,
      2 => localizations.statsWeekdayWed,
      3 => localizations.statsWeekdayThu,
      4 => localizations.statsWeekdayFri,
      5 => localizations.statsWeekdaySat,
      _ => localizations.statsWeekdaySun,
    };
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({
    required this.label,
    required this.plannedMinutes,
    required this.maxMinutes,
  });

  final String label;
  final int plannedMinutes;
  final int maxMinutes;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final ratio = maxMinutes == 0 ? 0.0 : plannedMinutes / maxMinutes;
    final barHeight = plannedMinutes == 0 ? 4.0 : 18.0 + ratio * 74.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: 96,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 20,
                height: barHeight,
                decoration: BoxDecoration(
                  color: plannedMinutes == 0
                      ? theme.colorScheme.surfaceContainerHighest
                      : theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: theme.textTheme.labelMedium),
          const SizedBox(height: 2),
          Text(
            localizations.statsBarMinutes(plannedMinutes),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletionBar extends StatelessWidget {
  const _CompletionBar({required this.summary});

  final StatsSummary summary;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                localizations.statsCompletionTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              localizations.statsCompletionPercent(summary.completionPercent),
              style: theme.textTheme.labelLarge,
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            minHeight: 12,
            value: summary.completionRate.clamp(0, 1),
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
      ],
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
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        if (plans.isEmpty)
          Text(
            localizations.statsTodayLedgerEmpty,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        else
          for (final plan in plans)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _LedgerRow(plan: plan),
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(time, style: theme.textTheme.labelMedium),
          ),
          Expanded(
            child: Text(
              plan.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            localizations.durationChipLabel(plan.durationMin),
            style: theme.textTheme.labelMedium,
          ),
          const SizedBox(width: 8),
          Text(
            '${_statusEmoji(plan.status)} ${_statusLabel(localizations, plan.status)}',
            style: theme.textTheme.labelMedium,
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
