import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:nudge/app/nudge_app.dart';
import 'package:nudge/app/providers.dart';
import 'package:nudge/domain/app_settings.dart';
import 'package:nudge/domain/plan.dart';
import 'package:nudge/domain/plan_repository.dart';
import 'package:nudge/domain/reminder_scheduler.dart';
import 'package:nudge/domain/settings_repository.dart';
import 'package:nudge/domain/todo.dart';
import 'package:nudge/domain/todo_repository.dart';
import 'package:nudge/features/pet/pet_mood.dart';
import 'package:nudge/features/pet/pet_providers.dart';
import 'package:nudge/l10n/generated/app_localizations_en.dart';
import 'package:nudge/l10n/generated/app_localizations_zh.dart';

void main() {
  testWidgets('shows the three-tab shell and switches tabs', (tester) async {
    final localizations = AppLocalizationsEn();

    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    expect(find.text(localizations.chatTabLabel), findsAtLeastNWidgets(1));
    expect(find.text(localizations.todosTabLabel), findsAtLeastNWidgets(1));
    expect(find.text(localizations.statsTabLabel), findsAtLeastNWidgets(1));

    // Chat → List: the placeholder empty state shows.
    await tester.tap(find.text(localizations.todosTabLabel).first);
    await tester.pumpAndSettle();
    expect(find.text(localizations.todosEmptyTitle), findsOneWidget);

    // List → Stats, then back to Chat: the list tab is no longer on screen.
    await tester.tap(find.text(localizations.statsTabLabel).first);
    await tester.pumpAndSettle();
    expect(find.text(localizations.todosEmptyTitle), findsNothing);

    await tester.tap(find.text(localizations.chatTabLabel).first);
    await tester.pumpAndSettle();
    expect(find.text(localizations.todosEmptyTitle), findsNothing);
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

  testWidgets('opens settings from the shared app bar', (tester) async {
    final localizations = AppLocalizationsEn();

    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip(localizations.settingsEntryTooltip));
    await tester.pumpAndSettle();

    expect(find.text(localizations.settingsTitle), findsOneWidget);
    expect(find.text(localizations.settingsDndLabel), findsOneWidget);
    expect(
      find.text(localizations.settingsVersionValue('9.9.9')),
      findsOneWidget,
    );

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
  });

  testWidgets('uses a persisted Chinese locale override', (tester) async {
    final localizations = AppLocalizationsZh();
    _setPlatformLocales(tester, const [Locale('en')]);

    await tester.pumpWidget(
      _buildApp(
        settingsRepository: _InMemorySettingsRepository(
          const AppSettings(dnd: false, localeOverride: LocaleOverride.zh),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(localizations.chatTabLabel), findsAtLeastNWidgets(1));
    expect(find.text(AppLocalizationsEn().chatTabLabel), findsNothing);
  });
}

Widget _buildApp({_InMemorySettingsRepository? settingsRepository}) {
  return ProviderScope(
    overrides: [
      planRepositoryProvider.overrideWithValue(const _EmptyPlanRepository()),
      todoRepositoryProvider.overrideWithValue(const _EmptyTodoRepository()),
      reminderSchedulerProvider.overrideWithValue(
        const _NoopReminderScheduler(),
      ),
      settingsRepositoryProvider.overrideWithValue(
        settingsRepository ?? _InMemorySettingsRepository(AppSettings.defaults),
      ),
      packageInfoProvider.overrideWith((ref) async => _testPackageInfo),
      petMoodProvider.overrideWithValue(PetMood.neutral),
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
  Future<Plan?> getActivePlan() async {
    return null;
  }

  @override
  Future<Plan?> getPlanById(int id) async {
    return null;
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

class _EmptyTodoRepository implements TodoRepository {
  const _EmptyTodoRepository();

  @override
  Stream<List<Todo>> watchTodos() => Stream.value(const []);

  @override
  Future<Todo?> getTodoById(int id) async => null;

  @override
  Future<Todo> createTodo({
    required String title,
    TodoPriority priority = TodoPriority.p2,
    DateTime? dueDate,
    String? note,
  }) => throw UnimplementedError();

  @override
  Future<void> updateTodo({
    required int id,
    String? title,
    TodoStatus? status,
    TodoPriority? priority,
    DateTime? dueDate,
    bool clearDueDate = false,
    String? note,
    bool clearNote = false,
  }) => throw UnimplementedError();

  @override
  Future<void> deleteTodo(int id) => throw UnimplementedError();

  @override
  Stream<List<TodoLog>> watchLogs(int todoId) => Stream.value(const []);

  @override
  Future<void> addLog({
    required int todoId,
    required String text,
    required TodoLogKind kind,
  }) => throw UnimplementedError();
}

class _NoopReminderScheduler implements ReminderScheduler {
  const _NoopReminderScheduler();

  @override
  Stream<int> get onCheckInTapped => const Stream.empty();

  @override
  Future<void> cancel(int planId) async {}

  @override
  Future<void> scheduleCheckInReminder({
    required int planId,
    required String title,
    required DateTime at,
    bool silent = false,
  }) async {}

  @override
  Future<int?> takeInitialTappedPlanId() async {
    return null;
  }
}

final _testPackageInfo = PackageInfo(
  appName: 'Nudge',
  packageName: 'com.nudge.app',
  version: '9.9.9',
  buildNumber: '99',
);

class _InMemorySettingsRepository implements SettingsRepository {
  _InMemorySettingsRepository(this.settings);

  AppSettings settings;

  @override
  Future<AppSettings> load() async {
    return settings;
  }

  @override
  Future<void> setDnd(bool value) async {
    settings = settings.copyWith(dnd: value);
  }

  @override
  Future<void> setLocaleOverride(LocaleOverride value) async {
    settings = settings.copyWith(localeOverride: value);
  }
}
