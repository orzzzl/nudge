import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nudge/app/nudge_app.dart';
import 'package:nudge/l10n/generated/app_localizations_en.dart';
import 'package:nudge/l10n/generated/app_localizations_zh.dart';

void main() {
  testWidgets('shows the two-tab shell and switches tabs', (tester) async {
    final localizations = AppLocalizationsEn();

    await tester.pumpWidget(const ProviderScope(child: NudgeApp()));
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

    await tester.pumpWidget(const ProviderScope(child: NudgeApp()));
    await tester.pumpAndSettle();

    expect(find.text(localizations.chatTabLabel), findsAtLeastNWidgets(1));
    expect(find.text(localizations.statsTabLabel), findsAtLeastNWidgets(1));
  });

  testWidgets('falls back to English for an unsupported locale', (
    tester,
  ) async {
    final localizations = AppLocalizationsEn();
    _setPlatformLocales(tester, const [Locale('fr')]);

    await tester.pumpWidget(const ProviderScope(child: NudgeApp()));
    await tester.pumpAndSettle();

    expect(find.text(localizations.chatTabLabel), findsAtLeastNWidgets(1));
    expect(find.text(localizations.statsTabLabel), findsAtLeastNWidgets(1));
  });
}

void _setPlatformLocales(WidgetTester tester, List<Locale> locales) {
  tester.binding.platformDispatcher.localesTestValue = locales;
  tester.binding.platformDispatcher.localeTestValue = locales.first;
  addTearDown(() {
    tester.binding.platformDispatcher.clearLocalesTestValue();
    tester.binding.platformDispatcher.clearLocaleTestValue();
  });
}
