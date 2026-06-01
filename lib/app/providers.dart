import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/app_database.dart';
import '../data/notify/local_reminder_scheduler.dart';
import '../data/repositories/plan_repository_impl.dart';
import '../domain/plan_repository.dart';
import '../domain/reminder_scheduler.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);

  return database;
});

final planRepositoryProvider = Provider<PlanRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);

  return PlanRepositoryImpl(database.plansDao);
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
