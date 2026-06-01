import 'dart:async';

abstract class ReminderScheduler {
  Future<void> scheduleCheckInReminder({
    required int planId,
    required String title,
    required DateTime at,
  });

  Future<void> cancel(int planId);

  Stream<int> get onCheckInTapped;

  Future<int?> takeInitialTappedPlanId();
}
