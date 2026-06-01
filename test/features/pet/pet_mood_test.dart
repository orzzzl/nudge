import 'package:flutter_test/flutter_test.dart';
import 'package:nudge/features/pet/pet_mood.dart';

void main() {
  test('is sad when there are no planned minutes', () {
    expect(
      petMoodFromStats(plannedMinutes: 0, completionRate: 1, streakDays: 7),
      PetMood.sad,
    );
  });

  test('is happy when the streak is at least three days', () {
    expect(
      petMoodFromStats(plannedMinutes: 30, completionRate: 0, streakDays: 3),
      PetMood.happy,
    );
  });

  test('is happy when completion reaches the threshold', () {
    expect(
      petMoodFromStats(plannedMinutes: 30, completionRate: 0.60, streakDays: 0),
      PetMood.happy,
    );
  });

  test('is neutral when engaged but below happy thresholds', () {
    expect(
      petMoodFromStats(plannedMinutes: 30, completionRate: 0.59, streakDays: 2),
      PetMood.neutral,
    );
  });
}
