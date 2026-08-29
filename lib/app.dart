import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_session.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'features/navigation/presentation/app_shell.dart';
import 'features/splash/presentation/splash_screen.dart';

class FoodlyApp extends StatefulWidget {
  const FoodlyApp({super.key, this.authSession});

  final AuthSession? authSession;

  @override
  State<FoodlyApp> createState() => _FoodlyAppState();
}

class _FoodlyAppState extends State<FoodlyApp> {
  _AppStage _stage = _AppStage.splash;
  late final AuthSession _authSession = widget.authSession ?? AuthSession();
  AuthUser? _user;

  Future<void> _checkAuthentication() async {
    final user = await _authSession.restoreSession();
    if (!mounted) return;
    setState(() {
      _user = user;
      _stage = user == null ? _AppStage.auth : _AppStage.app;
    });
  }

  void _openApp(AuthUser user) {
    setState(() {
      _user = user;
      _stage = _AppStage.app;
    });
  }

  Future<void> _logout() async {
    await _authSession.logout();
    if (!mounted) return;
    setState(() {
      _user = null;
      _stage = _AppStage.auth;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foodly AI',
      debugShowCheckedModeBanner: false,
      theme: FoodlyTheme.light,
      home: switch (_stage) {
        _AppStage.splash => SplashScreen(onFinished: _checkAuthentication),
        _AppStage.auth => AuthScreen(session: _authSession, onAuthenticated: _openApp),
        _AppStage.app => AppShell(user: _user!, onLogout: _logout),
      },
    );
  }
}

enum _AppStage { splash, auth, app }
