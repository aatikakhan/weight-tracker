import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weight_entry.dart';

class WeightEntryTile extends StatelessWidget {
  final WeightEntry entry;

  const WeightEntryTile(this.entry, {super.key});

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        DateFormat('dd MMMM yyyy hh:mm a').format(entry.date);
    return ListTile(
      title: entry.isMissed
          ? const Text(
              'You Missed',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            )
          : Text(
              'Weight: ${entry.weight} kg',
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
      subtitle: Text(formattedDate),
      tileColor: entry.isMissed ? Colors.red.shade100 : Colors.transparent,
    );
  }
}
