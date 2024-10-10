import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/weight_provider.dart';
import 'screens/home_screen.dart';
// import 'screens/settings_screen.dart';
import 'services/notification_service.dart';
import 'theme/theme.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  tz.initializeTimeZones();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeightProvider()),
        Provider(create: (_) => NotificationService()), // Provide NotificationService
      ],
      child: Consumer<WeightProvider>(
        builder: (context, weightProvider, child) {
          return MaterialApp(
            title: 'Weight Tracker',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: weightProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: '/',
            routes: {
              '/': (context) => const HomeScreen(),
              // '/settings': (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}
