import 'package:flutter/foundation.dart';

import '../../../core/services/foodly_api_service.dart';

class CartController extends ChangeNotifier {
  CartController({required this.api});

  final FoodlyApiService api;
  Map<String, dynamic> _cart = const {'items': [], 'subtotal': 0, 'deliveryFee': 0, 'total': 0};
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic> get cart => _cart;
  List<dynamic> get items => _cart['items'] as List<dynamic>? ?? const [];
  int get itemCount => items.fold(0, (sum, item) => sum + ((item as Map<String, dynamic>)['quantity'] as int));
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _cart = await api.getCart();
    } on FoodlyApiException catch (error) {
      _errorMessage = error.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> addItem(String foodItemId, {int quantity = 1}) => _change(
    () => api.addCartItem(foodItemId: foodItemId, quantity: quantity),
  );

  Future<String?> updateItem(String foodItemId, int quantity) => _change(
    () => api.updateCartItem(foodItemId: foodItemId, quantity: quantity),
  );

  Future<String?> removeItem(String foodItemId) => _change(() => api.removeCartItem(foodItemId));

  Future<String?> clear() => _change(api.clearCart);

  Future<Map<String, dynamic>?> createOrder({required String deliveryAddress}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final order = await api.createOrder(deliveryAddress: deliveryAddress);
      _cart = const {'items': [], 'subtotal': 0, 'deliveryFee': 0, 'total': 0};
      return order;
    } on FoodlyApiException catch (error) {
      _errorMessage = error.message;
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> _change(Future<Map<String, dynamic>> Function() change) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _cart = await change();
      return null;
    } on FoodlyApiException catch (error) {
      _errorMessage = error.message;
      return error.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
