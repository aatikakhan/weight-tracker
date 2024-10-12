import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weight_entry.dart';

class WeightEntryTile extends StatelessWidget {
  final WeightEntry entry;

  const WeightEntryTile(this.entry, {super.key});

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('E dd MMM').format(entry.date);

    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        title: entry.isMissed
            ? const Text(
                'You Missed',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              )
            : Text(
                'Weight: ${entry.weight} kg',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
        subtitle: Text(
          formattedDate,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        tileColor: entry.isMissed ? Colors.red.shade100 : Colors.transparent,
      ),
    );
  }
}
