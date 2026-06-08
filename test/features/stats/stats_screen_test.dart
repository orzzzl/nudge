import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nudge/app/providers.dart';
import 'package:nudge/domain/plan.dart';
import 'package:nudge/domain/plan_repository.dart';
import 'package:nudge/features/stats/stats_providers.dart';
import 'package:nudge/features/stats/stats_screen.dart';
import 'package:nudge/l10n/generated/app_localizations.dart';
import 'package:nudge/l10n/generated/app_localizations_en.dart';

void main() {
  testWidgets('renders weekly stats and today ledger from plans', (
    tester,
  ) async {
    final localizations = AppLocalizationsEn();
    final now = DateTime(2026, 6, 4, 12);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          planRepositoryProvider.overrideWithValue(
            _StaticPlanRepository([
              _plan(
                id: 1,
                title: 'Monday focus',
                startAt: DateTime(2026, 6, 1, 9),
                durationSec: 60 * 60,
                status: PlanStatus.done,
              ),
              _plan(
                id: 2,
                title: 'Write report',
                startAt: DateTime(2026, 6, 4, 10),
                durationSec: 60 * 60,
                status: PlanStatus.done,
              ),
            ]),
          ),
          statsNowProvider.overrideWithValue(now),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StatsScreen(),
        ),
      ),
    );
    await tester.pump();

    // Hero shows this week's planned hours (60 + 60 min = 2.0 h).
    expect(
      find.text(localizations.statsPlannedHoursValue('2.0')),
      findsOneWidget,
    );
    // The two line-chart cards + the range selector are present.
    expect(find.text(localizations.statsHoursChartTitle), findsOneWidget);
    expect(find.text(localizations.statsCompletionRateTitle), findsOneWidget);
    expect(find.text(localizations.statsRangeMonth), findsOneWidget);
    // Today's ledger still lists today's plan with its status.
    expect(find.text(localizations.statsTodayLedgerTitle), findsOneWidget);
    expect(find.text('Write report'), findsOneWidget);
    expect(find.text('✅ ${localizations.statsStatusDone}'), findsOneWidget);
  });
}

class _StaticPlanRepository implements PlanRepository {
  const _StaticPlanRepository(this.plans);

  final List<Plan> plans;

  @override
  Future<Plan> createPlan({
    required String title,
    required int durationSec,
    required DateTime startAt,
    required String locale,
    int? todoId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> checkIn({
    required int id,
    required PlanStatus status,
    String? note,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Plan?> getActivePlan() {
    throw UnimplementedError();
  }

  @override
  Future<Plan?> getPlanById(int id) {
    throw UnimplementedError();
  }

  @override
  Stream<List<Plan>> watchPlansForDay(DateTime day) {
    throw UnimplementedError();
  }

  @override
  Stream<List<Plan>> watchPlansInRange({
    required DateTime start,
    required DateTime end,
  }) {
    return Stream.value(plans);
  }
}

Plan _plan({
  required int id,
  required String title,
  required DateTime startAt,
  required int durationSec,
  required PlanStatus status,
}) {
  return Plan(
    id: id,
    todoId: null,
    title: title,
    durationSec: durationSec,
    startAt: startAt,
    endAt: startAt.add(Duration(seconds: durationSec)),
    status: status,
    note: null,
    locale: 'en',
    createdAt: startAt,
  );
}
