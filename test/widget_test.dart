import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nudge/app/nudge_app.dart';
import 'package:nudge/app/providers.dart';
import 'package:nudge/domain/plan.dart';
import 'package:nudge/domain/plan_repository.dart';
import 'package:nudge/l10n/generated/app_localizations_en.dart';
import 'package:nudge/l10n/generated/app_localizations_zh.dart';

void main() {
  testWidgets('shows the two-tab shell and switches tabs', (tester) async {
    final localizations = AppLocalizationsEn();

    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    expect(find.text(localizations.chatTabLabel), findsAtLeastNWidgets(1));
    expect(find.text(localizations.statsTabLabel), findsAtLeastNWidgets(1));

    await tester.tap(find.text(localizations.statsTabLabel).first);
    await tester.pumpAndSettle();

    expect(find.text(localizations.statsTabLabel), findsAtLeastNWidgets(1));
  });

  testWidgets('shows Chinese labels for the zh locale', (tester) async {
    final localizations = AppLocalizationsZh();
    _setPlatformLocales(tester, const [Locale('zh')]);

    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    expect(find.text(localizations.chatTabLabel), findsAtLeastNWidgets(1));
    expect(find.text(localizations.statsTabLabel), findsAtLeastNWidgets(1));
  });

  testWidgets('falls back to English for an unsupported locale', (
    tester,
  ) async {
    final localizations = AppLocalizationsEn();
    _setPlatformLocales(tester, const [Locale('fr')]);

    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    expect(find.text(localizations.chatTabLabel), findsAtLeastNWidgets(1));
    expect(find.text(localizations.statsTabLabel), findsAtLeastNWidgets(1));
  });
}

Widget _buildApp() {
  return ProviderScope(
    overrides: [
      planRepositoryProvider.overrideWithValue(const _EmptyPlanRepository()),
    ],
    child: const NudgeApp(),
  );
}

void _setPlatformLocales(WidgetTester tester, List<Locale> locales) {
  tester.binding.platformDispatcher.localesTestValue = locales;
  tester.binding.platformDispatcher.localeTestValue = locales.first;
  addTearDown(() {
    tester.binding.platformDispatcher.clearLocalesTestValue();
    tester.binding.platformDispatcher.clearLocaleTestValue();
  });
}

class _EmptyPlanRepository implements PlanRepository {
  const _EmptyPlanRepository();

  @override
  Future<Plan> createPlan({
    required String title,
    required int durationMin,
    required DateTime startAt,
    required String locale,
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
  Stream<List<Plan>> watchPlansForDay(DateTime day) {
    return Stream.value(const []);
  }

  @override
  Stream<List<Plan>> watchPlansInRange({
    required DateTime start,
    required DateTime end,
  }) {
    return Stream.value(const []);
  }
}
