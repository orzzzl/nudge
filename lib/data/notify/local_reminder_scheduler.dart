import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

import '../../domain/reminder_scheduler.dart';

const _channelId = 'plan_check_in_reminders';
const _channelName = 'Nudge';

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

      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _channelId,
              _channelName,
              importance: Importance.high,
            ),
          );

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
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
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
    final permissionsGranted = _permissionsGranted;
    if (permissionsGranted != null) {
      return permissionsGranted;
    }

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final androidNotificationsGranted =
        await android?.requestNotificationsPermission() ?? true;
    final androidExactAlarmsGranted =
        await android?.requestExactAlarmsPermission() ?? true;

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

    _permissionsGranted =
        androidNotificationsGranted &&
        androidExactAlarmsGranted &&
        iosGranted &&
        macOSGranted;
    return _permissionsGranted!;
  }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
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
