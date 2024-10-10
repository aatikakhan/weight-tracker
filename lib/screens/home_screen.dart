import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weight_provider.dart';
import '../services/notification_service.dart';
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

  void _scheduleNotification() async {
    final notificationService =
        Provider.of<NotificationService>(context, listen: false);

    // Request permission before scheduling notification
    await notificationService.requestPermission();

    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      notificationService.selectNotificationTime(time);
      await notificationService.scheduleDailyNotification(time);

      // Display a snack bar to indicate the scheduled time
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Notification scheduled for ${notificationService.getFormattedNotificationTime()}'),
        ),
      );

      // Trigger a rebuild to update the UI
      setState(() {});
    }
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
    final notificationService = Provider.of<NotificationService>(context);
    final weightProvider = Provider.of<WeightProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weight Tracker'),
        actions: [
          SizedBox(
            width: MediaQuery.of(context).size.width, // or a specific width
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              value: weightProvider.isDarkMode,
              onChanged: (value) {
                weightProvider.toggleTheme();
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Permanent tile to display scheduled notification time
          Container(
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Scheduled Notification Time:',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  notificationService.getFormattedNotificationTime(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<WeightProvider>(
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
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _addWeight,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _scheduleNotification,
            child: const Icon(Icons.alarm),
          ),
        ],
      ),
    );
  }
}
