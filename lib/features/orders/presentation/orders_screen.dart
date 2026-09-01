import 'package:flutter/material.dart';

import '../../../core/services/foodly_api_service.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key, required this.api});
  final FoodlyApiService api;

  @override
  State<OrdersScreen> createState() => OrdersScreenState();
}

class OrdersScreenState extends State<OrdersScreen> {
  List<dynamic> _orders = const [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final orders = await widget.api.getOrders();
      if (mounted) setState(() => _orders = orders);
    } on FoodlyApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> reload() => _load();

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: _load, child: const Text('Try again')),
            ],
          ),
        ),
      );
    }
    if (_orders.isEmpty) return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.receipt_long_outlined, size: 58), SizedBox(height: 14), Text("You haven't placed any orders yet.")]));
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (_, index) {
          final order = _orders[index] as Map<String, dynamic>;
          final items = order['items'] as List<dynamic>;
          return Card(
            child: ListTile(
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(builder: (_) => OrderDetailScreen(api: widget.api, orderId: order['id'] as String)));
                _load();
              },
              leading: const Icon(Icons.receipt_long_rounded),
              title: Text('Order #${(order['id'] as String).substring(0, 8)}'),
              subtitle: Text('${items.length} item(s) • ${(order['status'] as String).replaceAll('_', ' ')}'),
              trailing: Text('Rs. ${(order['total'] as num).toStringAsFixed(0)}'),
            ),
          );
        },
      ),
    );
  }
}
