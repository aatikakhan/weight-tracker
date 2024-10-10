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
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'weight_tracker.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
      CREATE TABLE weights(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        weight REAL,
        isMissed INTEGER DEFAULT 0
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
        date: DateTime.parse(maps[i]['date']),
        weight: maps[i]['weight'],
        isMissed: maps[i]['isMissed'] == 1, // Convert integer to bool
      );
    });
  }

  Future<void> deleteDatabase() async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
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
