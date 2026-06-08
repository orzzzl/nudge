import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nudge/features/chat/pending_composer_todo.dart';
import 'package:nudge/features/chat/widgets/plan_composer.dart';
import 'package:nudge/l10n/generated/app_localizations.dart';
import 'package:nudge/l10n/generated/app_localizations_en.dart';

void main() {
  late ProviderContainer container;
  final started = <({String title, int durationSec, int? todoId})>[];

  setUp(() {
    started.clear();
    container = ProviderContainer();
  });

  tearDown(() => container.dispose());

  Future<void> pumpComposer(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PlanComposer(
              onStart: (title, durationSec, todoId) => started.add((
                title: title,
                durationSec: durationSec,
                todoId: todoId,
              )),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  void queueTodo() {
    container.read(pendingComposerTodoProvider.notifier).set((
      todoId: 7,
      seq: 3,
      title: 'Write weekly report',
    ));
  }

  testWidgets('a queued todo replaces the title field with a chip', (
    tester,
  ) async {
    await pumpComposer(tester);

    expect(find.byKey(const Key('composerTitleField')), findsOneWidget);
    expect(find.byKey(const Key('composerTodoChip')), findsNothing);

    queueTodo();
    await tester.pump();

    expect(find.byKey(const Key('composerTodoChip')), findsOneWidget);
    expect(find.text('#3'), findsOneWidget);
    expect(find.text('Write weekly report'), findsOneWidget);
    expect(find.byKey(const Key('composerTitleField')), findsNothing);
    // The one-shot inbox is drained so re-entering the tab won't re-add it.
    expect(container.read(pendingComposerTodoProvider), isNull);
  });

  testWidgets('removing the chip restores manual input', (tester) async {
    await pumpComposer(tester);
    queueTodo();
    await tester.pump();

    await tester.tap(find.byKey(const Key('composerTodoChipRemove')));
    await tester.pump();

    expect(find.byKey(const Key('composerTodoChip')), findsNothing);
    expect(find.byKey(const Key('composerTitleField')), findsOneWidget);
  });

  testWidgets('starting with a chip carries the todo id and title', (
    tester,
  ) async {
    final l10n = AppLocalizationsEn();
    await pumpComposer(tester);
    queueTodo();
    await tester.pump();

    await tester.tap(find.text(l10n.startButton));
    await tester.pump();

    expect(started, hasLength(1));
    expect(started.single.title, 'Write weekly report');
    expect(started.single.todoId, 7);
    // Default preset is the 60-minute chip.
    expect(started.single.durationSec, 60 * 60);
  });

  testWidgets('starting from manual input carries a null todo id', (
    tester,
  ) async {
    final l10n = AppLocalizationsEn();
    await pumpComposer(tester);

    await tester.enterText(
      find.byKey(const Key('composerTitleField')),
      'Manual task',
    );
    await tester.tap(find.text(l10n.startButton));
    await tester.pump();

    expect(started, hasLength(1));
    expect(started.single.title, 'Manual task');
    expect(started.single.todoId, isNull);
  });
}
