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

    // Sort the weights by date after loading and checking missed days
    _weights.sort((a, b) => a.date.compareTo(b.date));

    notifyListeners();
  }

  Future<void> _checkForMissedDays() async {
    final now = DateTime.now();
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);

    if (_weights.isEmpty) return;

    final earliestDate = _weights
        .map((entry) => entry.date)
        .reduce((a, b) => a.isBefore(b) ? a : b);

    List<WeightEntry> missedEntries = [];

    for (DateTime dateToCheck = earliestDate;
        dateToCheck.isBefore(now) || dateToCheck.isAtSameMomentAs(now);
        dateToCheck = dateToCheck.add(const Duration(days: 1))) {
      if (dateToCheck.isBefore(endOfToday) &&
          !_weights.any((entry) => entry.date.isAtSameMomentAs(dateToCheck))) {
        missedEntries.add(WeightEntry(
          date: dateToCheck,
          weight: 0.0,
          isMissed: true,
        ));
      }
    }

    // Add missed entries and then sort
    _weights.addAll(missedEntries.where((missed) => !_weights.any((entry) =>
        entry.date.isAtSameMomentAs(missed.date) && entry.isMissed)));

    // Sort again after adding missed entries
    _weights.sort((a, b) => a.date.compareTo(b.date));
  }

  Future<void> addWeight(double weight, context) async {
    final today = DateTime.now();

    // Check if there's already an entry for today
    bool alreadyRecorded = _weights.any((entry) {
      final entryDate = entry.date;
      return entryDate.year == today.year &&
          entryDate.month == today.month &&
          entryDate.day == today.day;
    });

    if (alreadyRecorded) {
      // Notify the user that they cannot add another entry for today
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You can only add one weight entry per day!')),
      );
      return; // Exit the method early if an entry already exists
    }

    final entry = WeightEntry(
      id: null,
      date: today,
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
