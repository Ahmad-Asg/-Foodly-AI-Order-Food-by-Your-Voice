import 'package:flutter/material.dart';

class FoodlyColors {
  static const primary = Color(0xFFFF6B35);
  static const dark = Color(0xFF1F2937);
  static const surface = Color(0xFFFFFBF8);
}

class FoodlyTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: FoodlyColors.primary,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: FoodlyColors.surface,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: FoodlyColors.surface,
        foregroundColor: FoodlyColors.dark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: FoodlyColors.primary.withValues(alpha: 0.16),
        labelTextStyle: WidgetStatePropertyAll(
          const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}