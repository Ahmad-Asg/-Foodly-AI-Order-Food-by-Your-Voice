import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/navigation/presentation/app_shell.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/splash/presentation/splash_screen.dart';

class FoodlyApp extends StatefulWidget {
  const FoodlyApp({super.key});

  @override
  State<FoodlyApp> createState() => _FoodlyAppState();
}

class _FoodlyAppState extends State<FoodlyApp> {
  _AppStage _stage = _AppStage.splash;

  void _showOnboarding() {
    setState(() => _stage = _AppStage.onboarding);
  }

  void _openApp() {
    setState(() => _stage = _AppStage.app);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foodly AI',
      debugShowCheckedModeBanner: false,
      theme: FoodlyTheme.light,
      home: switch (_stage) {
        _AppStage.splash => SplashScreen(onFinished: _showOnboarding),
        _AppStage.onboarding => OnboardingScreen(onFinished: _openApp),
        _AppStage.app => const AppShell(),
      },
    );
  }
}

enum _AppStage { splash, onboarding, app }