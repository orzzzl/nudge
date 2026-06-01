enum PetMood { happy, neutral, sad }

PetMood petMoodFromStats({
  required int plannedMinutes,
  required double completionRate,
  required int streakDays,
}) {
  // Tunable mood rule: sad only when disengaged; happy when streak or
  // completion shows active engagement; neutral keeps low completion gentle.
  if (plannedMinutes == 0) {
    return PetMood.sad;
  }

  if (streakDays >= 3 || completionRate >= 0.60) {
    return PetMood.happy;
  }

  return PetMood.neutral;
}
