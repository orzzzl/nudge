import 'dart:async';

abstract class ReminderScheduler {
  /// Schedules the time-up reminder. When [silent] is true (the in-app
  /// Do-Not-Disturb setting), the notification still fires but makes no sound or
  /// vibration — independent of the phone's own silent/DND mode.
  Future<void> scheduleCheckInReminder({
    required int planId,
    required String title,
    required DateTime at,
    bool silent = false,
  });

  Future<void> cancel(int planId);

  Stream<int> get onCheckInTapped;

  Future<int?> takeInitialTappedPlanId();
}
