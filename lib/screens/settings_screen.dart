// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/weight_provider.dart';
// // import '../services/notification_service.dart';

// class SettingsScreen extends StatelessWidget {
//   const SettingsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final weightProvider = Provider.of<WeightProvider>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Settings'),
//       ),
//       body: Center(
//         // child: Column(
//         // mainAxisAlignment: MainAxisAlignment.center,
//         // children: [
//         // const Text('Set Notification Time:'),
//         // ElevatedButton(
//         //   onPressed: () async {
//         //     TimeOfDay? time = await showTimePicker(
//         //       context: context,
//         //       initialTime: weightProvider.notificationTime,
//         //     );
//         //     if (time != null) {
//         //       weightProvider.setNotificationTime(time);
//         //       await NotificationService().scheduleDailyNotification(time);
//         //     }
//         //   },
//         //   child: const Text('Select Time'),
//         // ),

//         child: SwitchListTile(
//           title: const Text('Dark Mode'),
//           value: weightProvider.isDarkMode,
//           onChanged: (value) {
//             weightProvider.toggleTheme();
//           },
//         ),
//         // ],
//         // ),
//       ),
//     );
//   }
// }
