import 'package:flutter/material.dart';

import '../../../core/services/foodly_api_service.dart';
import '../../cart/data/cart_controller.dart';
import 'food_detail_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key, required this.api, required this.cart});

  final FoodlyApiService api;
  final CartController cart;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<dynamic> _categories = const [];
  bool _isLoading = true;
  String? _error;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final menu = await widget.api.getMenu();
      if (mounted) setState(() => _categories = menu['categories'] as List<dynamic>? ?? const []);
    } on FoodlyApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: _loadMenu, child: const Text('Try again')),
        ]),
      ));
    }

    final visibleCategories = _selectedCategoryId == null
        ? _categories
        : _categories.where((entry) => (entry as Map<String, dynamic>)['_id'] == _selectedCategoryId).toList();
    return RefreshIndicator(
      onRefresh: _loadMenu,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Text('Foodly AI Restaurant', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Browse the real menu from Faisalabad.'),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(label: const Text('All'), selected: _selectedCategoryId == null, onSelected: (_) => setState(() => _selectedCategoryId = null)),
              ),
              ..._categories.map((entry) {
                final category = entry as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category['name'] as String),
                    selected: _selectedCategoryId == category['_id'],
                    onSelected: (_) => setState(() => _selectedCategoryId = category['_id'] as String),
                  ),
                );
              }),
            ]),
          ),
          const SizedBox(height: 18),
          ...visibleCategories.expand((entry) {
            final category = entry as Map<String, dynamic>;
            final items = category['items'] as List<dynamic>? ?? const [];
            return [
              Text(category['name'] as String, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...items.map((item) => _FoodCard(
                food: item as Map<String, dynamic>,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => FoodDetailScreen(api: widget.api, cart: widget.cart, foodId: item['_id'] as String),
                )),
              )),
              const SizedBox(height: 14),
            ];
          }),
        ],
      ),
    );
  }
}

class _FoodCard extends StatelessWidget {
  const _FoodCard({required this.food, required this.onTap});

  final Map<String, dynamic> food;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final price = (food['price'] as num).toStringAsFixed(0);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            _FoodImage(url: food['image'] as String?),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(food['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(food['description'] as String, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 7),
              Text('Rs. $price', style: const TextStyle(fontWeight: FontWeight.w600)),
            ])),
            const Icon(Icons.chevron_right_rounded),
          ]),
        ),
      ),
    );
  }
}

class _FoodImage extends StatelessWidget {
  const _FoodImage({required this.url});
  final String? url;

  @override
  Widget build(BuildContext context) {
    final imageUrl = url;
    if (imageUrl == null || imageUrl.isEmpty) return const SizedBox(width: 72, height: 72, child: Icon(Icons.fastfood_rounded));
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(imageUrl, width: 72, height: 72, fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox(width: 72, height: 72, child: Icon(Icons.fastfood_rounded))),
    );
  }
}
