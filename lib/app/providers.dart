import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../data/db/app_database.dart';
import '../data/notify/local_reminder_scheduler.dart';
import '../data/repositories/plan_repository_impl.dart';
import '../data/repositories/todo_repository_impl.dart';
import '../data/settings/shared_prefs_settings_repository.dart';
import '../domain/app_settings.dart';
import '../domain/plan_repository.dart';
import '../domain/reminder_scheduler.dart';
import '../domain/settings_repository.dart';
import '../domain/todo_repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);

  return database;
});

final planRepositoryProvider = Provider<PlanRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);

  return PlanRepositoryImpl(database.plansDao);
});

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);

  return TodoRepositoryImpl(database);
});

final reminderSchedulerProvider = Provider<ReminderScheduler>((ref) {
  final scheduler = LocalReminderScheduler();
  ref.onDispose(scheduler.dispose);

  return scheduler;
});

final reminderSchedulerInitializationProvider = FutureProvider<void>((
  ref,
) async {
  final scheduler = ref.watch(reminderSchedulerProvider);
  if (scheduler is LocalReminderScheduler) {
    await scheduler.initialize();
  }
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SharedPrefsSettingsRepository();
});

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    unawaited(_load());

    return AppSettings.defaults;
  }

  SettingsRepository get _repository => ref.read(settingsRepositoryProvider);

  Future<void> _load() async {
    final settings = await _repository.load();
    if (!ref.mounted) {
      return;
    }

    state = settings;
  }

  Future<void> setDnd(bool value) async {
    state = state.copyWith(dnd: value);
    await _repository.setDnd(value);
  }

  Future<void> setLocaleOverride(LocaleOverride value) async {
    state = state.copyWith(localeOverride: value);
    await _repository.setLocaleOverride(value);
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);

final packageInfoProvider = FutureProvider<PackageInfo>((ref) {
  return PackageInfo.fromPlatform();
});
