import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../data/cart_controller.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key, required this.cart});
  final CartController cart;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() { super.initState(); widget.cart.load(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your cart'),
        actions: [
          AnimatedBuilder(
            animation: widget.cart,
            builder: (_, _) => widget.cart.items.isEmpty ? const SizedBox.shrink() : TextButton(
              onPressed: widget.cart.isLoading ? null : () async {
                final error = await widget.cart.clear();
                if (!context.mounted || error == null) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
              },
              child: const Text('Clear'),
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.cart,
        builder: (_, _) {
          if (widget.cart.isLoading && widget.cart.items.isEmpty) return const Center(child: CircularProgressIndicator());
          if (widget.cart.errorMessage != null && widget.cart.items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.cart.errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    OutlinedButton(onPressed: widget.cart.load, child: const Text('Try again')),
                  ],
                ),
              ),
            );
          }
          if (widget.cart.items.isEmpty) return const _EmptyCart();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...widget.cart.items.map((entry) => _CartItem(item: entry as Map<String, dynamic>, cart: widget.cart)),
              const SizedBox(height: 12),
              _Totals(cart: widget.cart.cart),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: widget.cart.isLoading ? null : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CheckoutScreen(cart: widget.cart))),
                child: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Continue to checkout')),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CartItem extends StatelessWidget {
  const _CartItem({required this.item, required this.cart});
  final Map<String, dynamic> item;
  final CartController cart;

  @override
  Widget build(BuildContext context) {
    final food = item['food'] as Map<String, dynamic>;
    final quantity = item['quantity'] as int;
    final id = item['foodItemId'] as String;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(food['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Rs. ${(food['price'] as num).toStringAsFixed(0)} each'),
            const SizedBox(height: 8),
            Row(children: [
              IconButton(onPressed: cart.isLoading ? null : () => cart.updateItem(id, quantity - 1), icon: const Icon(Icons.remove_circle_outline)),
              Text('$quantity'),
              IconButton(onPressed: cart.isLoading ? null : () => cart.updateItem(id, quantity + 1), icon: const Icon(Icons.add_circle_outline)),
            ]),
          ])),
          Column(children: [
            Text('Rs. ${(item['lineTotal'] as num).toStringAsFixed(0)}', style: const TextStyle(color: FoodlyColors.primary, fontWeight: FontWeight.bold)),
            IconButton(onPressed: cart.isLoading ? null : () => cart.removeItem(id), icon: const Icon(Icons.delete_outline_rounded)),
          ]),
        ]),
      ),
    );
  }
}

class _Totals extends StatelessWidget {
  const _Totals({required this.cart});
  final Map<String, dynamic> cart;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _row('Subtotal', cart['subtotal'] as num),
        const SizedBox(height: 8),
        _row('Delivery fee', cart['deliveryFee'] as num),
        const Divider(height: 24),
        _row('Total', cart['total'] as num, bold: true),
      ]),
    ),
  );

  Widget _row(String label, num amount, {bool bold = false}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : null)), Text('Rs. ${amount.toStringAsFixed(0)}', style: TextStyle(fontWeight: bold ? FontWeight.bold : null))],
  );
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();
  @override
  Widget build(BuildContext context) => const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.shopping_cart_outlined, size: 58), SizedBox(height: 14), Text('Your cart is empty.'), SizedBox(height: 4), Text('Add something delicious from the menu.') ]));
}
