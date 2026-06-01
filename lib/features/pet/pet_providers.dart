import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../stats/stats_providers.dart';
import 'pet_mood.dart';

final petMoodProvider = Provider<PetMood>((ref) {
  final summary = ref.watch(statsSummaryProvider);

  return summary.maybeWhen(
    data: (data) => petMoodFromStats(
      plannedMinutes: data.plannedMinutes,
      completionRate: data.completionRate,
      streakDays: data.streakDays,
    ),
    orElse: () => PetMood.neutral,
  );
});
