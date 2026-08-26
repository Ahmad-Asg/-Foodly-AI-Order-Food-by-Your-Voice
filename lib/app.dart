import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/navigation/presentation/app_shell.dart';

class FoodlyApp extends StatelessWidget {
  const FoodlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foodly AI',
      debugShowCheckedModeBanner: false,
      theme: FoodlyTheme.light,
      home: const AppShell(),
    );
  }
}