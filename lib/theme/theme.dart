import 'package:flutter/material.dart';
import 'package:wetrack/constants/colors.dart';

class AppTheme {
  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    fontFamily: 'Lato',
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: AppColors.black),
      bodyMedium: TextStyle(color: AppColors.black),
      displayLarge: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      displayMedium: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
    ),
  );

  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.blueGrey,
    fontFamily: 'Lato',
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: AppColors.white),
      bodyMedium: TextStyle(color: AppColors.white),
      displayLarge: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      displayMedium: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
    ),
  );
}
