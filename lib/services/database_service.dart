import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/weight_entry.dart';

class DatabaseService {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    // Get the directory for the database
    final Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'weight_tracker.db'); // Create a path for the database file

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE weights(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            weight REAL
          )
        ''');
      },
    );
  }

  Future<void> insertWeight(WeightEntry entry) async {
    final db = await database;
    await db.insert(
      'weights',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<WeightEntry>> getWeights() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('weights');

    return List.generate(maps.length, (i) {
      return WeightEntry(
        id: maps[i]['id'],
        date: maps[i]['date'],
        weight: maps[i]['weight'],
      );
    });
  }

   Future<void> deleteDatabase() async {
    final Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'weight_tracker.db');

    final File dbFile = File(path);
    if (await dbFile.exists()) {
      await dbFile.delete();
      print('Database deleted: $path');
    } else {
      print('Database file does not exist.');
    }
  }
}
