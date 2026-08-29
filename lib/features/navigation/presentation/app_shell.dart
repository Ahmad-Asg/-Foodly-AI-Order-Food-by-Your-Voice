import 'package:flutter/material.dart';

import '../../auth/data/auth_session.dart';
import '../../home/presentation/home_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.user, required this.onLogout});

  final AuthUser user;
  final Future<void> Function() onLogout;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  late final List<Widget> _pages = [
    const HomeScreen(),
    const _ComingSoonPage(
      icon: Icons.search_rounded,
      title: 'Search',
      message: 'Food search will be added in a later phase.',
    ),
    const _ComingSoonPage(
      icon: Icons.auto_awesome_rounded,
      title: 'Foodly AI',
      message: 'AI chat and voice will be added in a later phase.',
    ),
    const _ComingSoonPage(
      icon: Icons.receipt_long_rounded,
      title: 'Orders',
      message: 'Your order history will appear here.',
    ),
    _ProfilePage(user: widget.user, onLogout: widget.onLogout),
  ];

  final List<String> _titles = const [
    'Foodly AI',
    'Search',
    'Foodly AI',
    'Orders',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex], style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search_rounded), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome_rounded), label: 'AI'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long_rounded), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage({required this.user, required this.onLogout});

  final AuthUser user;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          CircleAvatar(
            radius: 38,
            child: Text(user.name.isEmpty ? '?' : user.name.substring(0, 1).toUpperCase()),
          ),
          const SizedBox(height: 16),
          Text(user.name, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(user.email, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 28),
          OutlinedButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}

class _ComingSoonPage extends StatelessWidget {
  const _ComingSoonPage({required this.icon, required this.title, required this.message});

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
