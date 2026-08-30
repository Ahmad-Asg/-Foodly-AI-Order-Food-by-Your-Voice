import 'package:flutter/material.dart';

import '../../../core/services/foodly_api_service.dart';
import '../../cart/data/cart_controller.dart';

class FoodDetailScreen extends StatefulWidget {
  const FoodDetailScreen({super.key, required this.api, required this.cart, required this.foodId});
  final FoodlyApiService api;
  final CartController cart;
  final String foodId;

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  Map<String, dynamic>? _food;
  String? _error;
  int _quantity = 1;
  bool _isAdding = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final food = await widget.api.getFood(widget.foodId);
      if (mounted) setState(() => _food = food);
    } on FoodlyApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    }
  }

  Future<void> _addToCart() async {
    setState(() => _isAdding = true);
    final error = await widget.cart.addItem(widget.foodId, quantity: _quantity);
    if (!mounted) return;
    setState(() => _isAdding = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Added to cart.')));
  }

  @override
  Widget build(BuildContext context) {
    final food = _food;
    return Scaffold(
      appBar: AppBar(title: const Text('Food details')),
      body: food == null
          ? Center(child: _error == null ? const CircularProgressIndicator() : Text(_error!))
          : ListView(padding: const EdgeInsets.all(20), children: [
              if (food['image'] != null) ClipRRect(borderRadius: BorderRadius.circular(22), child: Image.network(food['image'] as String, height: 220, fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox(height: 140, child: Icon(Icons.fastfood_rounded, size: 56)))),
              const SizedBox(height: 20),
              Text(food['name'] as String, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Rs. ${(food['price'] as num).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              Text(food['description'] as String),
              const SizedBox(height: 18),
              _Info(title: 'Ingredients', value: (food['ingredients'] as List<dynamic>).join(', ')),
              _Info(title: 'Spice level', value: (food['spiceLevel'] as String).replaceAll('_', ' ')),
              const SizedBox(height: 22),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                IconButton(onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null, icon: const Icon(Icons.remove_circle_outline)),
                Text('$_quantity', style: Theme.of(context).textTheme.titleLarge),
                IconButton(onPressed: () => setState(() => _quantity++), icon: const Icon(Icons.add_circle_outline)),
              ]),
              const SizedBox(height: 10),
              FilledButton.icon(onPressed: _isAdding ? null : _addToCart, icon: const Icon(Icons.add_shopping_cart_rounded), label: Text(_isAdding ? 'Adding...' : 'Add to cart')),
            ]),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.title, required this.value});
  final String title;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 3), Text(value.isEmpty ? 'Not specified' : value)]),
  );
}
