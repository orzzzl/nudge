import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nudge/data/notify/local_reminder_scheduler.dart';

/// Drives the real [LocalReminderScheduler] against mocked plugin method
/// channels so we can assert *what* it schedules — not just that it schedules —
/// without a device. We assert the call arguments (channel id, importance,
/// sound, fire time, payload) because the silent-notification incidents proved
/// that "a call happened" is not the same as "an audible reminder fires".
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Channel contract — must match LocalReminderScheduler. Bumping the id is the
  // fix for Android's immutable channels: an updated install gets a fresh
  // channel with the new settings instead of inheriting the old ones. v3 moved
  // the reminder sound to the ALARM audio stream so it rings on a silenced
  // ringer.
  const expectedChannelId = 'plan_check_in_reminders_v3';
  const legacyChannelIds = [
    'plan_check_in_reminders',
    'plan_check_in_reminders_v2',
  ];

  const localNotifChannel = MethodChannel(
    'dexterous.com/flutter/local_notifications',
  );
  const timezoneChannel = MethodChannel('flutter_timezone');

  late List<MethodCall> calls;
  // Per-test permission state so we can exercise the grant/deny matrix.
  late bool notificationsGranted;
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  MethodCall callTo(String method) =>
      calls.firstWhere((c) => c.method == method);
  bool called(String method) => calls.any((c) => c.method == method);

  setUp(() {
    calls = [];
    notificationsGranted = true;
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
          return notificationsGranted;
        case 'requestPermissions': // iOS/macOS permission request
          return notificationsGranted;
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
    'creates a high-importance channel WITH SOUND and deletes the stale one',
    () async {
      // Regression guard for the silent-notification incident: Android channels are
      // immutable, so a previously-silent channel keeps its settings on an
      // updated install. The fix recreates under a new id (audible) and deletes
      // the legacy one. This fails on the pre-fix scheduler, which neither
      // bumped the id nor deleted the old channel.
      final scheduler = LocalReminderScheduler();
      await scheduler.initialize();

      expect(
        called('deleteNotificationChannel'),
        isTrue,
        reason: 'the stale (possibly silent) channels must be deleted',
      );
      final deleted = calls
          .where((c) => c.method == 'deleteNotificationChannel')
          .map((c) => c.arguments)
          .toList();
      expect(deleted, containsAll(legacyChannelIds));

      final channel = callTo('createNotificationChannel').arguments as Map;
      expect(channel['id'], expectedChannelId);
      expect(
        channel['importance'],
        Importance.high.value,
        reason: 'high importance is what makes it a heads-up + audible alert',
      );
      expect(
        channel['playSound'],
        isTrue,
        reason: 'sound must be explicit, not left to the default',
      );
      expect(
        channel['audioAttributesUsage'],
        AudioAttributesUsage.alarm.value,
        reason:
            'the alarm stream is what makes the reminder ring on a silenced '
            'ringer, like a clock alarm',
      );
    },
  );

  test(
    'schedules with the right channel, sound, fire time and payload',
    () async {
      final scheduler = LocalReminderScheduler();
      final at = DateTime.now().add(const Duration(minutes: 5));

      await scheduler.scheduleCheckInReminder(
        planId: 7,
        title: 'smoke',
        at: at,
      );

      final schedule = callTo('zonedSchedule').arguments as Map;
      expect(schedule['id'], 7);
      expect(
        schedule['payload'],
        '7',
        reason: 'tap routing keys off the planId',
      );

      // Fire time must round-trip faithfully (guards timezone / durationSec math).
      final scheduled = DateTime.parse(
        schedule['scheduledDateTimeISO8601'] as String,
      );
      expect(scheduled.isAtSameMomentAs(at), isTrue);

      final android = schedule['platformSpecifics'] as Map;
      expect(android['channelId'], expectedChannelId);
      expect(android['importance'], Importance.high.value);
      expect(android['priority'], Priority.high.value);
      expect(android['playSound'], isTrue);
      expect(
        android['audioAttributesUsage'],
        AudioAttributesUsage.alarm.value,
        reason: 'pre-8 devices take audio attributes per notification',
      );
      expect(
        android['scheduleMode'],
        AndroidScheduleMode.alarmClock.name,
        reason: 'setAlarmClock is what delivers exactly at time-up',
      );
    },
  );

  test(
    'falls back to an inexact alarm when exact alarms are not permitted',
    () async {
      // Regression guard for the third silent-reminder incident: the plugin
      // gates alarmClock behind canScheduleExactAlarms() on Android 12+ and
      // throws exact_alarms_not_permitted when the app holds neither
      // USE_EXACT_ALARM nor SCHEDULE_EXACT_ALARM. The pre-fix scheduler let
      // that exception escape, so NO reminder existed at all. A late reminder
      // must win over a missing one.
      messenger.setMockMethodCallHandler(localNotifChannel, (call) async {
        calls.add(call);
        switch (call.method) {
          case 'initialize':
            return true;
          case 'getNotificationAppLaunchDetails':
            return null;
          case 'requestNotificationsPermission':
            return true;
          case 'zonedSchedule':
            final android = call.arguments['platformSpecifics'] as Map;
            if (android['scheduleMode'] ==
                AndroidScheduleMode.alarmClock.name) {
              throw PlatformException(code: 'exact_alarms_not_permitted');
            }
            return null;
          default:
            return null;
        }
      });

      final scheduler = LocalReminderScheduler();
      await scheduler.scheduleCheckInReminder(
        planId: 11,
        title: 'smoke',
        at: DateTime.now().add(const Duration(minutes: 5)),
      );

      final schedules = calls
          .where((c) => c.method == 'zonedSchedule')
          .map((c) => c.arguments as Map)
          .toList();
      expect(schedules, hasLength(2));

      final fallback = schedules.last['platformSpecifics'] as Map;
      expect(
        fallback['scheduleMode'],
        AndroidScheduleMode.inexactAllowWhileIdle.name,
      );
      expect(schedules.last['id'], 11);
      expect(
        fallback['channelId'],
        expectedChannelId,
        reason: 'the fallback must keep the loud alarm-stream channel',
      );
    },
  );

  test('creates both a loud and a silent channel on init', () async {
    final scheduler = LocalReminderScheduler();
    await scheduler.initialize();

    final channels = calls
        .where((c) => c.method == 'createNotificationChannel')
        .map((c) => c.arguments as Map)
        .toList();
    final ids = channels.map((m) => m['id']).toList();
    expect(
      ids,
      containsAll(<String>[
        expectedChannelId,
        'plan_check_in_reminders_silent',
      ]),
    );

    final silent = channels.firstWhere(
      (m) => m['id'] == 'plan_check_in_reminders_silent',
    );
    expect(silent['importance'], Importance.low.value);
    expect(silent['playSound'], isFalse);
  });

  test(
    'schedules on the silent channel (no sound) when silent: true',
    () async {
      // Backs the in-app DND setting: still delivered, but quiet.
      final scheduler = LocalReminderScheduler();

      await scheduler.scheduleCheckInReminder(
        planId: 5,
        title: 'smoke',
        at: DateTime.now().add(const Duration(minutes: 5)),
        silent: true,
      );

      final android =
          callTo('zonedSchedule').arguments['platformSpecifics'] as Map;
      expect(android['channelId'], 'plan_check_in_reminders_silent');
      expect(android['importance'], Importance.low.value);
      expect(android['playSound'], isFalse);
      expect(
        android['audioAttributesUsage'],
        AudioAttributesUsage.notification.value,
        reason:
            'in-app DND must stay on the notification stream — the alarm '
            'stream is only for the loud channel',
      );
    },
  );

  test(
    'schedules a check-in reminder even when exact-alarm permission is denied',
    () async {
      // Guards the earlier "no reminder at time-up" fix: notifications granted +
      // exact-alarm denied (Android 12+ default) must still schedule.
      final scheduler = LocalReminderScheduler();

      await scheduler.scheduleCheckInReminder(
        planId: 1,
        title: 'smoke',
        at: DateTime.now().add(const Duration(minutes: 5)),
      );

      expect(called('zonedSchedule'), isTrue);
    },
  );

  test(
    'does NOT schedule when the notification permission is denied',
    () async {
      notificationsGranted = false;
      final scheduler = LocalReminderScheduler();

      await scheduler.scheduleCheckInReminder(
        planId: 2,
        title: 'smoke',
        at: DateTime.now().add(const Duration(minutes: 5)),
      );

      expect(called('zonedSchedule'), isFalse);
    },
  );

  test(
    'does NOT schedule a reminder whose time is already in the past',
    () async {
      final scheduler = LocalReminderScheduler();

      await scheduler.scheduleCheckInReminder(
        planId: 3,
        title: 'smoke',
        at: DateTime.now().subtract(const Duration(minutes: 1)),
      );

      expect(called('zonedSchedule'), isFalse);
    },
  );

  test(
    'still initializes (channel created) when the timezone is unknown',
    () async {
      // Some devices/emulators report a tz id absent from the tz database, which
      // throws in getLocation. The scheduler must fall back to UTC instead of
      // aborting init — otherwise the channel never gets created and reminders are
      // silently dead. (This is the failure the on-device smoke test surfaced.)
      messenger.setMockMethodCallHandler(timezoneChannel, (call) async {
        if (call.method == 'getLocalTimezone') {
          return 'Etc/Definitely_Not_A_Real_Zone';
        }
        return null;
      });

      final scheduler = LocalReminderScheduler();
      await scheduler.initialize(); // must not throw

      expect(called('createNotificationChannel'), isTrue);
    },
  );

  test('iOS schedules with presentSound so the alert is audible', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    FlutterLocalNotificationsPlatform.instance =
        IOSFlutterLocalNotificationsPlugin();

    final scheduler = LocalReminderScheduler();
    await scheduler.scheduleCheckInReminder(
      planId: 9,
      title: 'smoke',
      at: DateTime.now().add(const Duration(minutes: 5)),
    );

    final ios = callTo('zonedSchedule').arguments['platformSpecifics'] as Map;
    expect(ios['presentSound'], isTrue);
  });
}
