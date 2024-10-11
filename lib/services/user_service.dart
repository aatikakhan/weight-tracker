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

  // Check if this is the first run of the app
  Future<bool> isFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_first_run') ?? true; // Return true if not set
  }
}
