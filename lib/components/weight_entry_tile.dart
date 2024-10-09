

import 'package:flutter/material.dart';
import '../models/weight_entry.dart';

class WeightEntryTile extends StatelessWidget {
  final WeightEntry entry;

  const WeightEntryTile(this.entry, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('${entry.weight} kg'),
      subtitle: Text(entry.date),
    );
  }
}
