import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/app_database.dart';
import '../data/repositories/plan_repository_impl.dart';
import '../domain/plan_repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);

  return database;
});

final planRepositoryProvider = Provider<PlanRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);

  return PlanRepositoryImpl(database.plansDao);
});
