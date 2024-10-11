import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final DatabaseService _databaseService = DatabaseService();

  // Set the user's name in the database
  Future<void> setUserName(String name) async {
    final db = await _databaseService.database;

    try {
      await db.insert(
        'user',
        {'name': name},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      // Also mark that the app has run at least once
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_first_run', false);
    } catch (e) {
      print('Error setting user name: $e');
    }
  }

  // Retrieve the user's name from the database
  Future<String?> getUserName() async {
    final db = await _databaseService.database;

    try {
      final List<Map<String, dynamic>> maps = await db.query('user');

      // Check if the user exists and return their name
      if (maps.isNotEmpty) {
        print('User found: ${maps.first['name']}');
        return maps.first['name'] as String;
      }

      print('No user found.');
      return null;
    } catch (e) {
      print('Error retrieving user name: $e');
      return null;
    }
  }

  // Check if this is the first run of the app
  Future<bool> isFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_first_run') ?? true; // Return true if not set
  }
}
