import 'package:flutter/material.dart';
import 'package:linkup/core/utils/app_colors.dart';

class AppTheme {
  static _border([Color color = AppColors.borderColor]) => OutlineInputBorder(
        // borderSide: BorderSide(color: color, width: 3),
        borderRadius: BorderRadius.circular(20),
      );
  static final darkThemeMode = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppColors.backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundColor,
      elevation: 0,
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: AppColors.backgroundColor,
      side: BorderSide.none,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.all(24),
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _border(AppColors.gradient2),
        errorBorder: _border(AppColors.errorColor),
        filled: true,
        fillColor: const Color.fromARGB(62, 148, 163, 199)),
  );
}
