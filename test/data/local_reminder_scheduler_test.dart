import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nudge/data/notify/local_reminder_scheduler.dart';

/// Drives the real [LocalReminderScheduler] against mocked plugin method
/// channels so we can assert its scheduling behaviour without a device.
///
/// Regression guard for the "计时到点收不到提醒" bug: on Android 12+,
/// `SCHEDULE_EXACT_ALARM` is denied by default. The scheduler used to AND the
/// exact-alarm grant into an all-or-nothing permission gate, so a user who had
/// granted notifications but not exact alarms got **no notification at all**.
/// A check-in nudge tolerates a small delay, so it must still be scheduled when
/// notifications are allowed, regardless of the exact-alarm grant.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const localNotifChannel = MethodChannel(
    'dexterous.com/flutter/local_notifications',
  );
  const timezoneChannel = MethodChannel('flutter_timezone');

  late List<MethodCall> calls;
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    calls = [];
    // resolvePlatformSpecificImplementation keys off defaultTargetPlatform AND
    // the registered platform instance, so pretend we're on Android and
    // register the Android implementation (normally done by plugin registration).
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    FlutterLocalNotificationsPlatform.instance =
        AndroidFlutterLocalNotificationsPlugin();

    messenger.setMockMethodCallHandler(timezoneChannel, (call) async {
      if (call.method == 'getLocalTimezone') {
        return 'UTC';
      }
      return null;
    });

    messenger.setMockMethodCallHandler(localNotifChannel, (call) async {
      calls.add(call);
      switch (call.method) {
        case 'initialize':
          return true;
        case 'getNotificationAppLaunchDetails':
          return null;
        case 'requestNotificationsPermission':
          return true; // notifications GRANTED
        case 'requestExactAlarmsPermission':
          return false; // exact alarms DENIED — Android 12+ default
        default:
          return null;
      }
    });
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    messenger.setMockMethodCallHandler(localNotifChannel, null);
    messenger.setMockMethodCallHandler(timezoneChannel, null);
  });

  test(
    'schedules a check-in reminder even when exact-alarm permission is denied',
    () async {
      final scheduler = LocalReminderScheduler();

      await scheduler.scheduleCheckInReminder(
        planId: 1,
        title: 'smoke',
        at: DateTime.now().add(const Duration(minutes: 5)),
      );

      final scheduled = calls.any((c) => c.method == 'zonedSchedule');
      expect(
        scheduled,
        isTrue,
        reason:
            'notifications are granted, so a reminder must be scheduled even '
            'without exact-alarm permission (it can degrade to an inexact alarm)',
      );
    },
  );
}
