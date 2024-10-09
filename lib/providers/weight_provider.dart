import 'package:flutter/material.dart';
import '../models/weight_entry.dart';
import '../services/database_service.dart';

class WeightProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<WeightEntry> _weights = [];
  TimeOfDay _notificationTime = TimeOfDay.now();
  bool _isDarkMode = false;

  List<WeightEntry> get weights => _weights;
  TimeOfDay get notificationTime => _notificationTime;
  bool get isDarkMode => _isDarkMode;

  Future<void> loadWeights() async {
    _weights = await _databaseService.getWeights();
    notifyListeners();
  }

  Future<void> addWeight(double weight) async {
    final entry = WeightEntry(
      id: 0, // 0 for auto-increment
      date: DateTime.now().toString(),
      weight: weight,
    );
    await _databaseService.insertWeight(entry);
    await loadWeights(); // Refresh the list after adding
  }

  void setNotificationTime(TimeOfDay time) {
    _notificationTime = time;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
