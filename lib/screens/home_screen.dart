import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weight_provider.dart';
import '../services/notification_service.dart';
import '../components/weight_entry_tile.dart';
import '../services/user_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _userName;

  @override
  void initState() {
    super.initState();
    _checkForUserName();
    Provider.of<WeightProvider>(context, listen: false).loadWeights();
  }

  Future<void> _checkForUserName() async {
    final userService = UserService();
    if (await userService.isFirstRun()) {
      print('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');

      String? userName = await showDialog(
        context: context,
        builder: (context) {
          String tempName = '';
          return AlertDialog(
            title: const Text('Enter Your Name'),
            content: TextField(
              onChanged: (value) {
                tempName = value;
              },
              decoration: const InputDecoration(hintText: "Your name"),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(tempName);
                },
                child: const Text('Submit'),
              ),
            ],
          );
        },
      );

      if (userName != null && userName.isNotEmpty) {
        await userService.setUserName(userName);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Welcome, $userName!')),
        );

        // Ask user to set notification time
        TimeOfDay? notificationTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );

        if (notificationTime != null) {
          final notificationService =
              Provider.of<NotificationService>(context, listen: false);
          await notificationService.scheduleDailyNotification(notificationTime);
          setState(() {
            _userName = userName; // Store the name for display
          });
        }
      }
    } else {
      _userName = await userService.getUserName();
      setState(() {});
    }
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
              )
            ]);
      },
    );

    if (weight != null && weight > 0) {
      // Call your WeightProvider to add the weight
      Provider.of<WeightProvider>(context, listen: false).addWeight(weight);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationService = Provider.of<NotificationService>(context);
    final weightProvider = Provider.of<WeightProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_userName != null
            ? 'Weight Tracker - $_userName'
            : 'Weight Tracker'),
        actions: [
          IconButton(
            icon: Icon(
              weightProvider.isDarkMode
                  ? Icons.brightness_4_outlined
                  : Icons.brightness_4_outlined,
            ),
            onPressed: () {
              weightProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Consumer<WeightProvider>(
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
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: _addWeight,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
