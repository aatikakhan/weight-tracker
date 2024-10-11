import 'package:flutter/material.dart';
import 'package:wetrack/constants/colors.dart';

class AppTheme {
  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.black,
    fontFamily: 'Lato',
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: AppColors.black),
      bodyMedium: TextStyle(color: AppColors.black),
      bodySmall: TextStyle(color: AppColors.greydark),
      displayLarge: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      displayMedium: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.black,
      foregroundColor: AppColors.white, 
    ),
  );

  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.white,
    fontFamily: 'Lato',
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: AppColors.white),
      bodyMedium: TextStyle(color: AppColors.white),
      bodySmall: TextStyle(color: AppColors.greydark),
      displayLarge: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      displayMedium: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.white, 
      foregroundColor: AppColors.greydark,
    ),
  );
}
