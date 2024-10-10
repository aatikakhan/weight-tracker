import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Android Initialization Settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // Use your icon here

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: DarwinInitializationSettings(),
    );

    // Initialize the plugin
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Create a notification channel
    await _createNotificationChannel();
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'your_channel_id', // Unique channel ID
      'your_channel_name', // User-visible channel name
      description: 'Channel for weight tracker notifications',
      importance: Importance.high, // Importance level
      playSound: true, // Play sound when a notification is received
    );

    // Create the channel on the device
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> scheduleDailyNotification(TimeOfDay time) async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Weight Tracker Reminder',
      'Don\'t forget to record your weight today!',
      _nextInstanceOfTime(time),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your_channel_id',
          'your_channel_name',
          channelDescription: 'Channel for weight tracker notifications',
          importance: Importance.high, // Set importance level
          priority: Priority.high, // Set priority level
          playSound: true, // Enable sound
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true, // Show alert
          presentBadge: true, // Badge app icon
          presentSound: true, // Play sound
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
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

    // If the scheduled time is already passed, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
