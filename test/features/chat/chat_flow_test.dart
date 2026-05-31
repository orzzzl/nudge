import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nudge/app/providers.dart';
import 'package:nudge/data/db/app_database.dart' as db;
import 'package:nudge/data/repositories/plan_repository_impl.dart';
import 'package:nudge/features/chat/chat_screen.dart';
import 'package:nudge/l10n/generated/app_localizations.dart';
import 'package:nudge/l10n/generated/app_localizations_en.dart';

void main() {
  late db.AppDatabase database;

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> pumpChat(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          planRepositoryProvider.overrideWithValue(
            PlanRepositoryImpl(database.plansDao),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ChatScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('create -> countdown -> check-in clears the active plan', (
    tester,
  ) async {
    final l10n = AppLocalizationsEn();
    await pumpChat(tester);

    // Greeting is shown and the start button is disabled until a title exists.
    expect(find.text(l10n.chatGreeting), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );

    // Fill the fixed-format input and start the block.
    await tester.enterText(find.byType(TextField), 'Write report');
    await tester.pump();
    await tester.tap(find.text(l10n.durationChipLabel(90)));
    await tester.pump();
    await tester.tap(find.text(l10n.startButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Confirmation bubble + capsule appear; the composer is gone.
    expect(
      find.text(l10n.planConfirmation('Write report', 90)),
      findsOneWidget,
    );
    expect(find.text(l10n.capsuleCheckIn), findsOneWidget);
    expect(find.text(l10n.startButton), findsNothing);

    // Open the check-in sheet and pick "done".
    await tester.tap(find.text(l10n.capsuleCheckIn));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(l10n.checkInTitle), findsOneWidget);

    await tester.tap(find.text(l10n.checkInDone));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    // Active plan cleared: composer returns and a result bubble is appended.
    expect(find.text(l10n.resultDone), findsOneWidget);
    expect(find.text(l10n.startButton), findsOneWidget);
    expect(find.text(l10n.capsuleCheckIn), findsNothing);
  });
}
