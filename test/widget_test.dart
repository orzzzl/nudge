import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nudge/app/nudge_app.dart';

void main() {
  testWidgets('shows the two-tab shell and switches tabs', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: NudgeApp()));
    await tester.pumpAndSettle();

    expect(find.text('Chat'), findsAtLeastNWidgets(1));
    expect(find.text('Stats'), findsAtLeastNWidgets(1));

    await tester.tap(find.text('Stats').first);
    await tester.pumpAndSettle();

    expect(find.text('Stats'), findsAtLeastNWidgets(1));
  });
}
