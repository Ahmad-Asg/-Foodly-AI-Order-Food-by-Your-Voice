import 'package:flutter/material.dart';

import '../data/cart_controller.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.cart});
  final CartController cart;
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressController = TextEditingController();
  bool _isPlacingOrder = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_isPlacingOrder) return;
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your delivery address.')),
      );
      return;
    }
    setState(() => _isPlacingOrder = true);
    final order = await widget.cart.createOrder(
      deliveryAddress: _addressController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isPlacingOrder = false);
    if (order == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.cart.errorMessage ?? 'Unable to place your order.',
          ),
        ),
      );
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order placed!'),
        content: Text(
          'Order #${(order['id'] as String).substring(0, 8)} is placed.\nTotal: Rs. ${(order['total'] as num).toStringAsFixed(0)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
    if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final cart = widget.cart.cart;
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Delivery information',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addressController,
            maxLines: 2,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Delivery address',
              hintText: 'Enter your full delivery address',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          Text('Payment', style: Theme.of(context).textTheme.titleLarge),
          const ListTile(
            leading: Icon(Icons.payments_outlined),
            title: Text('Cash on Delivery'),
            subtitle: Text('Mock payment for this demo'),
          ),
          const Divider(height: 32),
          _line('Subtotal', cart['subtotal'] as num),
          _line('Delivery fee', cart['deliveryFee'] as num),
          const Divider(),
          _line('Total', cart['total'] as num, bold: true),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isPlacingOrder ? null : _placeOrder,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(_isPlacingOrder ? 'Placing order...' : 'Place Order'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(String label, num amount, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: bold ? FontWeight.bold : null),
        ),
        Text(
          'Rs. ${amount.toStringAsFixed(0)}',
          style: TextStyle(fontWeight: bold ? FontWeight.bold : null),
        ),
      ],
    ),
  );
}
