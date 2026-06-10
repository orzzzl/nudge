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
// — the silent-notification incident. Bumping the id forces a fresh channel
// with the correct high-importance + sound settings on every updated install, and we
// delete the stale ones so the user isn't left with a dead channel in settings.
// If the channel definition below ever changes again, bump the suffix and add
// the previous id to [_legacyChannelIds].
const _channelId = 'plan_check_in_reminders_v3';
const _channelName = 'Nudge';

// Channel sound/importance is IMMUTABLE per channel, so "loud" and "silent" must
// be two separate channels picked at schedule time — we can't toggle one
// channel's sound at runtime. The silent channel backs the in-app DND setting.
const _silentChannelId = 'plan_check_in_reminders_silent';
const _silentChannelName = 'Nudge (quiet)';

/// Old channel ids to delete on init so their stale (silent) settings can't
/// linger on updated installs. v2 was the notification-stream channel,
/// superseded by the alarm-stream v3.
const _legacyChannelIds = <String>[
  'plan_check_in_reminders',
  'plan_check_in_reminders_v2',
];

/// The loud reminder channel — high importance so it makes a heads-up sound,
/// with sound explicitly on (don't rely on the default). The sound plays on the
/// ALARM audio stream, like a clock alarm: it rings even when the ringer is on
/// silent/vibrate, at the system alarm volume, and passes the default "alarms"
/// exception of system DND. Time-up is the product's one promise, so it
/// intentionally outranks ringer silence (owner decision 2026-06-09,
/// superseding the #30 "OS silent always wins" contract). The in-app DND
/// switch still routes to [_silentChannel] instead.
const _reminderChannel = AndroidNotificationChannel(
  _channelId,
  _channelName,
  importance: Importance.high,
  playSound: true,
  audioAttributesUsage: AudioAttributesUsage.alarm,
);

/// The quiet channel for in-app DND — still shows in the shade, but low
/// importance with no sound and no vibration.
const _silentChannel = AndroidNotificationChannel(
  _silentChannelId,
  _silentChannelName,
  importance: Importance.low,
  playSound: false,
  enableVibration: false,
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
      try {
        final localTimezone = await FlutterTimezone.getLocalTimezone();
        timezone.setLocalLocation(
          timezone.getLocation(localTimezone.identifier),
        );
      } catch (_) {
        // Some devices/emulators report a timezone id that isn't in the tz
        // database (e.g. "Etc/Unknown"), which throws and would abort the whole
        // init — leaving the channel uncreated and reminders silently dead
        // (another flavour of the silent-notification bug). Fall back to UTC:
        // zonedSchedule uses absolute instants, so the fire time stays correct.
        timezone.setLocalLocation(timezone.getLocation('UTC'));
      }

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
        await android.createNotificationChannel(_silentChannel);
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
    bool silent = false,
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
      _notificationDetails(silent: silent),
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

  NotificationDetails _notificationDetails({required bool silent}) {
    if (silent) {
      // In-app DND: deliver quietly via the silent channel. iOS/pre-8 Android
      // honour the per-notification flags too, so set sound off there as well.
      return const NotificationDetails(
        android: AndroidNotificationDetails(
          _silentChannelId,
          _silentChannelName,
          importance: Importance.low,
          priority: Priority.low,
          playSound: false,
          enableVibration: false,
        ),
        iOS: DarwinNotificationDetails(presentSound: false),
        macOS: DarwinNotificationDetails(presentSound: false),
      );
    }
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        importance: Importance.high,
        priority: Priority.high,
        // Sound is a channel-level setting on Android 8+, but set it here too so
        // pre-8 devices (and the test contract) get an audible notification.
        playSound: true,
        // Mirror the channel's alarm-stream usage for pre-8 devices, where
        // audio attributes are per-notification rather than per-channel.
        audioAttributesUsage: AudioAttributesUsage.alarm,
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
