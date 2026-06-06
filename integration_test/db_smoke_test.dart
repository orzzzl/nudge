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

  testWidgets('round-trips a plan through the on-device database', (
    tester,
  ) async {
    // Running under the native XCTest runner (`xcodebuild test`) turns on iOS
    // accessibility, which makes the engine open a SemanticsHandle mid-test that
    // flutter_test's end-of-test leak check flags ("A SemanticsHandle was active
    // at the end of the test"). The `flutter test -d <sim>` path never enables
    // accessibility, so this only bites under XCTest. Hold semantics on for the
    // whole body and dispose it before returning, so the handle count ends back
    // at its baseline. Cheap no-op for this non-UI test.
    final semantics = tester.ensureSemantics();

    final startAt = DateTime.now();

    final plan = await repository.createPlan(
      title: 'smoke',
      durationSec: 30 * 60,
      startAt: startAt,
      locale: 'en',
    );

    expect(plan.id, isNotNull);

    final id = plan.id!;
    final storedPlan = await repository.getPlanById(id);

    expect(storedPlan, isNotNull);
    expect(storedPlan!.title, 'smoke');
    expect(storedPlan.durationSec, 30 * 60);
    expect(storedPlan.status, PlanStatus.running);

    await repository.checkIn(id: id, status: PlanStatus.done);

    final checkedInPlan = await repository.getPlanById(id);

    expect(checkedInPlan, isNotNull);
    expect(checkedInPlan!.status, PlanStatus.done);

    semantics.dispose();
  });
}
