import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  print('Notification tapped in background: ${notificationResponse.payload}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const String _channelId = 'weight_tracker_channel';
  static const String _channelName = 'Weight Tracker Notifications';

  TimeOfDay? _notificationTime;

  Future<void> init() async {
    print("Initializing NotificationService...");
    await _configureLocalTimeZone();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        print('Received iOS notification: $title');
      },
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        print('Notification tapped: ${notificationResponse.payload}');
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    await _createNotificationChannel();
    print("NotificationService initialized successfully.");
  }

  Future<void> _configureLocalTimeZone() async {
    try {
      tz.initializeTimeZones();
      final String timeZoneName = 'Asia/Kolkata'; // Set to Asia/Kolkata
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      print("Timezone configured: $timeZoneName");
    } catch (e) {
      print("Error configuring timezone: $e");
    }
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Channel for weight tracker notifications',
      importance: Importance.high,
      playSound: true,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    print("Notification channel created.");
  }

  void selectNotificationTime(TimeOfDay time) {
    _notificationTime = time;
    print("Notification time selected: ${time.hour}:${time.minute}");
  }

  Future<void> saveNotificationTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notification_hour', time.hour);
    await prefs.setInt('notification_minute', time.minute);
  }

  Future<TimeOfDay?> loadNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt('notification_hour');
    final minute = prefs.getInt('notification_minute');

    if (hour != null && minute != null) {
      return TimeOfDay(hour: hour, minute: minute);
    }
    return null; // Return null if no time is stored
  }

  String getFormattedNotificationTime() {
    if (_notificationTime != null) {
      final now = tz.TZDateTime.now(tz.local);
      final dateTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        _notificationTime!.hour,
        _notificationTime!.minute,
      );
      return DateFormat.jm().format(dateTime);
    }
    return 'Not set';
  }

  Future<void> scheduleDailyNotification(String? userName) async {
    // Load the notification time from SharedPreferences
    final storedTime = await loadNotificationTime();
    if (storedTime != null) {
      _notificationTime = storedTime; // Set the notification time
    }

    if (_notificationTime == null) {
      print('Notification time is not set. Please select a time first.');
      return;
    }

    bool notificationGranted = await requestPermission();
    bool exactAlarmGranted = await requestExactAlarmPermission();

    if (!notificationGranted || !exactAlarmGranted) {
      print('Notification or exact alarm permission not granted.');
      return;
    }

    print('Scheduling notification...');
    final scheduledDate = _nextInstanceOfTime(_notificationTime!);
    print('Scheduled date: $scheduledDate');

    try {
      String notificationBody = userName != null
          ? 'Hey $userName, don\'t forget to record your weight today!'
          : 'Don\'t forget to record your weight today!';

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Weight Tracker Reminder',
        notificationBody,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: 'Channel for weight tracker notifications',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'weight_tracker_payload',
      );

      print(
          'Notification scheduled successfully at ${getFormattedNotificationTime()}');
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the scheduled time is in the past, add one day
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  Future<bool> requestPermission() async {
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      print('Notification permission not granted, requesting...');
      status = await Permission.notification.request();
    }
    print('Notification permission status: ${status.isGranted}');
    return status.isGranted;
  }

  Future<bool> requestExactAlarmPermission() async {
    if (await Permission.scheduleExactAlarm.isRestricted) {
      print('Exact alarm permission is restricted.');
      return false;
    }

    var status = await Permission.scheduleExactAlarm.status;
    if (!status.isGranted) {
      print('Exact alarm permission not granted, requesting...');
      status = await Permission.scheduleExactAlarm.request();
    }
    print('Exact alarm permission status: ${status.isGranted}');
    return status.isGranted;
  }
}
