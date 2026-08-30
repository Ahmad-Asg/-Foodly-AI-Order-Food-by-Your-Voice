import 'package:flutter/material.dart';

import '../../../core/services/foodly_api_service.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.api, required this.orderId});
  final FoodlyApiService api;
  final String orderId;
  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Map<String, dynamic>? _order;
  String? _error;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    try { final order = await widget.api.getOrder(widget.orderId); if (mounted) setState(() => _order = order); }
    on FoodlyApiException catch (error) { if (mounted) setState(() => _error = error.message); }
  }
  @override
  Widget build(BuildContext context) {
    final order = _order;
    return Scaffold(
      appBar: AppBar(title: const Text('Order details')),
      body: order == null ? Center(child: _error == null ? const CircularProgressIndicator() : Text(_error!)) : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Order #${(order['id'] as String).substring(0, 8)}', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text('Status: ${(order['status'] as String).replaceAll('_', ' ')}'),
          const Divider(height: 28),
          ...(order['items'] as List<dynamic>).map((entry) {
            final item = entry as Map<String, dynamic>;
            return ListTile(contentPadding: EdgeInsets.zero, title: Text('${item['name']} × ${item['quantity']}'), trailing: Text('Rs. ${(item['lineTotal'] as num).toStringAsFixed(0)}'));
          }),
          const Divider(height: 28),
          _line('Subtotal', order['subtotal'] as num),
          _line('Delivery fee', order['deliveryFee'] as num),
          _line('Total', order['total'] as num, bold: true),
          if ((order['deliveryAddress'] as String).isNotEmpty) ...[const SizedBox(height: 20), Text('Delivery address', style: Theme.of(context).textTheme.titleSmall), Text(order['deliveryAddress'] as String)],
          const SizedBox(height: 10),
          const Text('Payment: Cash on Delivery'),
        ],
      ),
    );
  }
  Widget _line(String label, num amount, {bool bold = false}) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : null)), Text('Rs. ${amount.toStringAsFixed(0)}', style: TextStyle(fontWeight: bold ? FontWeight.bold : null))]));
}
