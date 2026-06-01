import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nudge/features/pet/pet_mood.dart';
import 'package:nudge/features/pet/pet_view.dart';

void main() {
  for (final mood in PetMood.values) {
    testWidgets('renders TuanTuan for $mood at chat and stats sizes', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                PetView(mood: mood, size: 22),
                PetView(mood: mood, size: 48),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(PetView), findsNWidgets(2));
      expect(
        find.descendant(
          of: find.byType(PetView),
          matching: find.byType(CustomPaint),
        ),
        findsNWidgets(2),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
