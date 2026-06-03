import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

import '../../domain/reminder_scheduler.dart';

// Android notification channels are IMMUTABLE after first creation: once a
// channel id exists on a device, later changes to its importance/sound are
// ignored until reinstall. An earlier build shipped this channel and a silent
// (or low-importance) install kept those settings even after the code was fixed
// — the "通知不响" incident. Bumping the id forces a fresh channel with the
// correct high-importance + sound settings on every updated install, and we
// delete the stale ones so the user isn't left with a dead channel in settings.
// If the channel definition below ever changes again, bump the suffix and add
// the previous id to [_legacyChannelIds].
const _channelId = 'plan_check_in_reminders_v2';
const _channelName = 'Nudge';

/// Old channel ids to delete on init so their stale (silent) settings can't
/// linger on updated installs.
const _legacyChannelIds = <String>['plan_check_in_reminders'];

/// The single source of truth for the reminder channel — high importance so it
/// makes a heads-up sound, with sound explicitly on (don't rely on the default).
const _reminderChannel = AndroidNotificationChannel(
  _channelId,
  _channelName,
  importance: Importance.high,
  playSound: true,
);

class LocalReminderScheduler implements ReminderScheduler {
  LocalReminderScheduler({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  final _tapController = StreamController<int>.broadcast();

  Future<void>? _initialization;
  bool _initialized = false;
  bool? _permissionsGranted;
  int? _initialTappedPlanId;

  Future<void> initialize() {
    if (_initialized) {
      return Future<void>.value();
    }

    return _initialization ??= _initialize();
  }

  Future<void> _initialize() async {
    try {
      timezone_data.initializeTimeZones();
      final localTimezone = await FlutterTimezone.getLocalTimezone();
      timezone.setLocalLocation(timezone.getLocation(localTimezone.identifier));

      await _plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
          macOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: _handleNotificationResponse,
      );

      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null) {
        // Drop stale channels first so a previously-silent one can't shadow the
        // new high-importance channel (channels are immutable; deleting is the
        // only way to change settings on an already-installed device).
        for (final legacyId in _legacyChannelIds) {
          await android.deleteNotificationChannel(legacyId);
        }
        await android.createNotificationChannel(_reminderChannel);
      }

      final launchDetails = await _plugin.getNotificationAppLaunchDetails();
      if (launchDetails?.didNotificationLaunchApp ?? false) {
        _initialTappedPlanId = _parsePlanId(
          launchDetails?.notificationResponse?.payload,
        );
      }

      _initialized = true;
    } finally {
      if (!_initialized) {
        _initialization = null;
      }
    }
  }

  @override
  Future<void> scheduleCheckInReminder({
    required int planId,
    required String title,
    required DateTime at,
  }) async {
    await initialize();

    if (!at.isAfter(DateTime.now())) {
      return;
    }

    final permissionsGranted = await _requestPermissions();
    if (!permissionsGranted) {
      return;
    }

    await _plugin.zonedSchedule(
      planId,
      title,
      null,
      timezone.TZDateTime.from(at, timezone.local),
      _notificationDetails(),
      // alarmClock routes through AlarmManager.setAlarmClock: exact delivery
      // even in Doze, and — unlike exactAllowWhileIdle — exempt from the
      // SCHEDULE_EXACT_ALARM permission, so the reminder fires on time for
      // every user with no extra setup. Fits the "nudge you right at time-up"
      // promise without the permission gate that used to drop notifications.
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      payload: planId.toString(),
    );
  }

  @override
  Future<void> cancel(int planId) async {
    await initialize();
    await _plugin.cancel(planId);
  }

  @override
  Stream<int> get onCheckInTapped => _tapController.stream;

  @override
  Future<int?> takeInitialTappedPlanId() async {
    await initialize();

    final planId = _initialTappedPlanId;
    _initialTappedPlanId = null;

    return planId;
  }

  Future<bool> _requestPermissions() async {
    // Only the notification permission gates scheduling. Exact timing is handled
    // by AndroidScheduleMode.alarmClock (no SCHEDULE_EXACT_ALARM needed), so we
    // deliberately do NOT couple exact-alarm grant in here — doing so used to
    // drop the reminder entirely for users who hadn't enabled exact alarms.
    if (_permissionsGranted == true) {
      return true;
    }

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final androidGranted =
        await android?.requestNotificationsPermission() ?? true;

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final iosGranted =
        await ios?.requestPermissions(alert: true, badge: true, sound: true) ??
        true;

    final macOS = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    final macOSGranted =
        await macOS?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        true;

    final granted = androidGranted && iosGranted && macOSGranted;
    // Cache only a positive result: a denial can be reversed in system settings,
    // so re-request next time rather than silencing reminders for the session.
    if (granted) {
      _permissionsGranted = true;
    }
    return granted;
  }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        importance: Importance.high,
        priority: Priority.high,
        // Sound is a channel-level setting on Android 8+, but set it here too so
        // pre-8 devices (and the test contract) get an audible notification.
        playSound: true,
      ),
      // presentSound: true makes the notification audible in the foreground on
      // iOS/macOS (the default, pinned so a future edit can't silence it).
      iOS: DarwinNotificationDetails(presentSound: true),
      macOS: DarwinNotificationDetails(presentSound: true),
    );
  }

  void _handleNotificationResponse(NotificationResponse response) {
    final planId = _parsePlanId(response.payload);
    if (planId == null) {
      return;
    }

    _tapController.add(planId);
  }

  int? _parsePlanId(String? payload) {
    if (payload == null) {
      return null;
    }

    return int.tryParse(payload);
  }

  Future<void> dispose() {
    return _tapController.close();
  }
}
