import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  // Set the user's name in shared preferences
  Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    
    // Also mark that the app has run at least once
    await prefs.setBool('is_first_run', false);
  }

  // Retrieve the user's name from shared preferences
  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name'); // Return the user's name
  }

  // Save notification time
  Future<void> saveNotificationTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notification_hour', time.hour);
    await prefs.setInt('notification_minute', time.minute);
  }

  // Retrieve notification time
  Future<TimeOfDay?> getNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt('notification_hour');
    final minute = prefs.getInt('notification_minute');

    if (hour != null && minute != null) {
      return TimeOfDay(hour: hour, minute: minute);
    }
    return null; // Return null if not set
  }

  // Check if this is the first run of the app
  Future<bool> isFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_first_run') ?? true; // Return true if not set
  }
}
