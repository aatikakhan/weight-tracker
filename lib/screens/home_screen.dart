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
    _userName = await userService.getUserName();
    
    // Check for user's name
    if (_userName == null || _userName!.isEmpty) {
      // Prompt for username if not set
      String? userName = await _showUserNameDialog();
      if (userName != null && userName.isNotEmpty) {
        await userService.setUserName(userName);

        // Ask user to set notification time
        await _selectNotificationTime(userName);
      } else {
        // If no name is provided, recheck the user name
        _checkForUserName();
      }
    } else {
      // If the username is already set, check for notification time
      await _checkForNotificationTime();
    }
  }

  Future<void> _checkForNotificationTime() async {
    final userService = UserService();
    TimeOfDay? notificationTime = await userService.getNotificationTime();
    
    if (notificationTime == null) {
      // Ask user to set notification time
      await _selectNotificationTime(_userName!);
    } else {
      setState(() {});
    }
  }

  Future<void> _selectNotificationTime(String userName) async {
    TimeOfDay? notificationTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    // If the user selected a notification time
    if (notificationTime != null) {
      final notificationService =
          Provider.of<NotificationService>(context, listen: false);
      notificationService.selectNotificationTime(notificationTime);
      await notificationService.scheduleDailyNotification(userName);
      
      final userService = UserService();
      await userService.saveNotificationTime(notificationTime); // Save the notification time

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notification time set to ${notificationTime.format(context)}!')),
      );
    } else {
      // If no notification time is set, ask again
      await _selectNotificationTime(userName);
    }
  }

  Future<String?> _showUserNameDialog() {
    return showDialog<String>(
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
  }

  void _addWeight() async {
    double? weight = await _showWeightDialog();

    if (weight != null && weight > 0) {
      await Provider.of<WeightProvider>(context, listen: false)
          .addWeight(weight, context);
    }
  }

  Future<double?> _showWeightDialog() {
    return showDialog<double>(
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
  }

  void _changeNotificationTime() async {
    TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (newTime != null) {
      final notificationService =
          Provider.of<NotificationService>(context, listen: false);
      notificationService.selectNotificationTime(newTime);
      await notificationService.saveNotificationTime(newTime); // Save new time
      await notificationService
          .scheduleDailyNotification(_userName); // Reschedule notification

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Notification time updated to ${newTime.format(context)}!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          IconButton(
            icon: const Icon(Icons.access_time),
            onPressed: _changeNotificationTime, // Change notification time
          ),
        ],
      ),
      body: Column(
        children: [
          Consumer<WeightProvider>(
            builder: (context, weightProvider, child) {
              List weightList = weightProvider.weights.reversed.toList();
              return Expanded(
                child: ListView.builder(
                  itemCount: weightList.length,
                  itemBuilder: (context, index) {
                    return WeightEntryTile(weightList[index]);
                  },
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: _addWeight,
        child: const Icon(Icons.add),
      ),
    );
  }
}
