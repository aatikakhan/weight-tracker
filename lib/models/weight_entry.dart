class WeightEntry {
  final int id;
  final String date;
  final double weight;

  WeightEntry({
    required this.id,
    required this.date,
    required this.weight,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'weight': weight,
    };
  }

  factory WeightEntry.fromMap(Map<String, dynamic> map) {
    return WeightEntry(
      id: map['id'],
      date: map['date'],
      weight: map['weight'],
    );
  }
}
