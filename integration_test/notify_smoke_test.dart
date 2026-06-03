import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nudge/data/notify/local_reminder_scheduler.dart';

/// On-device guard for the silent-notification incidents. Host tests can prove
/// we *call* the plugin with the right arguments, but only a real device proves
/// the whole native chain actually fires and POSTS a notification: channel
/// creation, AlarmManager scheduling, the alarm firing, and the notification
/// reaching the status bar.
///
/// Runs on an Android emulator whose API level grants notifications by default
/// (pre-Android-13), so there is no permission dialog to tap — see the
/// `android-notify-smoke` job in `.github/workflows/db-smoke.yml`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const planId = 4242;

  testWidgets('schedules a reminder that actually fires and posts', (_) async {
    final scheduler = LocalReminderScheduler();
    addTearDown(scheduler.dispose);

    await scheduler.initialize();

    // A couple of seconds out — per-second durations make this fast to verify.
    await scheduler.scheduleCheckInReminder(
      planId: planId,
      title: 'smoke',
      at: DateTime.now().add(const Duration(seconds: 2)),
    );

    final android = FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    expect(android, isNotNull, reason: 'this smoke test is Android-only');

    // Poll: the alarm fires ~2s out, but emulators are not perfectly punctual,
    // so wait up to ~20s for the notification to land in the status bar.
    var posted = false;
    for (var i = 0; i < 40 && !posted; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      final active = await android!.getActiveNotifications();
      posted = active.any((n) => n.id == planId);
    }

    expect(
      posted,
      isTrue,
      reason:
          'the scheduled reminder must actually fire and post a notification — '
          'this is exactly what the "通知不响" incidents broke',
    );

    await scheduler.cancel(planId);
  });
}
