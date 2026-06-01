import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nudge/data/db/app_database.dart';
import 'package:nudge/data/repositories/plan_repository_impl.dart';
import 'package:nudge/domain/plan.dart';
import 'package:nudge/domain/plan_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late PlanRepository repository;

  setUp(() {
    database = AppDatabase();
    repository = PlanRepositoryImpl(database.plansDao);
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('round-trips a plan through the on-device database', (_) async {
    final startAt = DateTime.now();

    final plan = await repository.createPlan(
      title: 'smoke',
      durationMin: 30,
      startAt: startAt,
      locale: 'en',
    );

    expect(plan.id, isNotNull);

    final id = plan.id!;
    final storedPlan = await repository.getPlanById(id);

    expect(storedPlan, isNotNull);
    expect(storedPlan!.title, 'smoke');
    expect(storedPlan.durationMin, 30);
    expect(storedPlan.status, PlanStatus.running);

    await repository.checkIn(id: id, status: PlanStatus.done);

    final checkedInPlan = await repository.getPlanById(id);

    expect(checkedInPlan, isNotNull);
    expect(checkedInPlan!.status, PlanStatus.done);
  });
}
