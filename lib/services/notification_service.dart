import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

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
       final String timeZoneName = 'Asia/Kolkata'; 
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

  Future<void> scheduleDailyNotification(TimeOfDay time) async {
    bool notificationGranted = await requestPermission();
    bool exactAlarmGranted = await requestExactAlarmPermission();

    if (!notificationGranted || !exactAlarmGranted) {
      print('Notification or exact alarm permission not granted.');
      return;
    }

    print('Scheduling notification...');
    final scheduledDate = _nextInstanceOfTime(time);
    print('Scheduled date: $scheduledDate');
    print('Current date: ${tz.TZDateTime.now(tz.local)}');

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Weight Tracker Reminder',
        'Don\'t forget to record your weight today!',
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

      // Check pending notifications
      await checkPendingNotifications();

      // Immediately show a test notification
      await _showTestNotification();
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

    // If the scheduled time is less than 1 minute in the future, add one more day
    if (scheduledDate.difference(now) < const Duration(minutes: 1)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  Future<void> _showTestNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Channel for weight tracker notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      0,
      'Test Notification',
      'This is a test notification',
      platformChannelSpecifics,
      payload: 'test_payload',
    );
    print('Test notification sent.');
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

  Future<void> checkPendingNotifications() async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
    print(
        'Number of pending notifications: ${pendingNotificationRequests.length}');
    for (var notification in pendingNotificationRequests) {
      print(
          'Pending notification: ID ${notification.id}, Title: ${notification.title}, Body: ${notification.body}');
    }
  }
}
