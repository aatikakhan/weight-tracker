class WeightEntry {
  final int? id;
  final DateTime date;
  final double weight;
  final bool isMissed;

  WeightEntry({
    this.id,
    required this.date,
    required this.weight,
    this.isMissed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(), // Convert DateTime to String for storage
      'weight': weight,
      'isMissed': isMissed ? 1 : 0, // Convert bool to int for storage
    };
  }

  factory WeightEntry.fromMap(Map<String, dynamic> map) {
    return WeightEntry(
      id: map['id'],
      date: DateTime.parse(map['date']), // Parse String to DateTime
      weight: map['weight'],
      isMissed: map['isMissed'] == 1, // Convert int to bool
    );
  }
}
