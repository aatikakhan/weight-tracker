import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weight_provider.dart';
import '../components/weight_entry_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<WeightProvider>(context, listen: false).loadWeights();
  }

  void _addWeight() async {
    double? weight = await showDialog(
      context: context,
      builder: (context) {
        double tempWeight = 0;
        return AlertDialog(
          title: const Text('Add Weight'),
          content: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              tempWeight = double.tryParse(value) ?? 0;
            },
            decoration: const InputDecoration(hintText: "Enter your weight"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(tempWeight);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (weight != null && weight > 0) {
      await Provider.of<WeightProvider>(context, listen: false)
          .addWeight(weight);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weight Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Consumer<WeightProvider>(
        builder: (context, weightProvider, child) {
          List weightList = weightProvider.weights.reversed.toList();
          return ListView.builder(
            itemCount: weightList.length,
            itemBuilder: (context, index) {
              return WeightEntryTile(weightList[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addWeight,
        child: const Icon(Icons.add),
      ),
    );
  }
}
