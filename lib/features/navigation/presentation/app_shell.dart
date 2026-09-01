import 'package:flutter/material.dart';

import '../../../core/services/foodly_api_service.dart';
import '../../auth/data/auth_session.dart';
import '../../ai_chat/presentation/ai_chat_screen.dart';
import '../../cart/data/cart_controller.dart';
import '../../cart/presentation/cart_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../../menu/presentation/menu_screen.dart';
import '../../orders/presentation/orders_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.user,
    required this.api,
    required this.cart,
    required this.onLogout,
  });

  final AuthUser user;
  final FoodlyApiService api;
  final CartController cart;
  final Future<void> Function() onLogout;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  final _ordersKey = GlobalKey<OrdersScreenState>();

  late final List<Widget> _pages = [
    HomeScreen(api: widget.api, user: widget.user, onCartChanged: widget.cart.load),
    MenuScreen(api: widget.api, cart: widget.cart),
    AiChatScreen(api: widget.api, onCartChanged: widget.cart.load),
    OrdersScreen(key: _ordersKey, api: widget.api),
    _ProfilePage(user: widget.user, onLogout: widget.onLogout),
  ];

  final List<String> _titles = const [
    'Foodly AI',
    'Menu',
    'Foodly AI',
    'Orders',
    'Profile',
  ];

  @override
  void initState() {
    super.initState();
    widget.cart.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          AnimatedBuilder(
            animation: widget.cart,
            builder: (_, _) => IconButton(
              tooltip: 'Cart',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CartScreen(cart: widget.cart),
                ),
              ),
              icon: Badge(
                isLabelVisible: widget.cart.itemCount > 0,
                label: Text('${widget.cart.itemCount}'),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
          if (index == 3) _ordersKey.currentState?.reload();
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu_rounded),
            label: 'Menu',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome_rounded),
            label: 'AI',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
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
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        CircleAvatar(
          radius: 38,
          child: Text(
            user.name.isEmpty ? '?' : user.name.substring(0, 1).toUpperCase(),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user.name,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black54),
        ),
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
