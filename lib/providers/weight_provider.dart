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
    await _checkForMissedDays();
    notifyListeners();
  }

  Future<void> _checkForMissedDays() async {
    final now = DateTime.now();

    // If there are no weights recorded, do nothing
    if (_weights.isEmpty) return;

    // Find the earliest date from recorded weights
    final earliestDate = _weights
        .map((entry) => entry.date)
        .reduce((a, b) => a.isBefore(b) ? a : b);

    List<WeightEntry> missedEntries = [];

    // Check each day from the earliest entry date to today
    for (DateTime dateToCheck = earliestDate;
        dateToCheck.isBefore(now) || dateToCheck.isAtSameMomentAs(now);
        dateToCheck = dateToCheck.add(const Duration(days: 1))) {
      // Check if the date is in the list of recorded weight dates
      if (!_weights.any((entry) => entry.date.isAtSameMomentAs(dateToCheck))) {
        missedEntries.add(WeightEntry(
          date: dateToCheck, // Use DateTime directly
          weight: 0.0, // No weight recorded
          isMissed: true,
        ));
      }
    }

    // Add missed entries to the list, avoiding duplicates
    _weights.addAll(missedEntries.where((missed) => !_weights.any((entry) =>
        entry.date.isAtSameMomentAs(missed.date) && entry.isMissed)));
  }

  Future<void> addWeight(double weight) async {
    final entry = WeightEntry(
      id: null,
      date: DateTime.now(),
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
