import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class FoodlyApiException implements Exception {
  const FoodlyApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// A small API client for the Phase 5 single-restaurant endpoints.
/// It is intentionally not connected to the mock Phase 3 screens yet.
class FoodlyApiService {
  FoodlyApiService({http.Client? client, this._tokenProvider})
    : _client = client ?? http.Client();

  final http.Client _client;
  final Future<String?> Function()? _tokenProvider;

  Future<Map<String, dynamic>> getRestaurant() => _getObject('restaurant');

  Future<List<dynamic>> getCategories() => _getList('categories');

  Future<List<dynamic>> getFoods({
    String? category,
    num? maxPrice,
    String? spiceLevel,
  }) {
    final queryParameters = <String, String>{};
    if (category != null) queryParameters['category'] = category;
    if (maxPrice != null) queryParameters['maxPrice'] = maxPrice.toString();
    if (spiceLevel != null) queryParameters['spiceLevel'] = spiceLevel;
    return _getList('foods', queryParameters: queryParameters);
  }

  Future<Map<String, dynamic>> getFood(String id) => _getObject('foods/$id');

  Future<Map<String, dynamic>> getMenu() => _getObject('menu');

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) => _postObject(
    'auth/register',
    body: {'name': name, 'email': email, 'password': password},
  );

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) => _postObject('auth/login', body: {'email': email, 'password': password});

  Future<Map<String, dynamic>> getCurrentUser() => _getObject('auth/me');

  Future<Map<String, dynamic>> getCart() => _getObject('cart');

  Future<Map<String, dynamic>> addCartItem({
    required String foodItemId,
    int quantity = 1,
  }) => _postObject(
    'cart/items',
    body: {'foodItemId': foodItemId, 'quantity': quantity},
  );

  Future<Map<String, dynamic>> updateCartItem({
    required String foodItemId,
    required int quantity,
  }) => _sendObject(
    'PATCH',
    'cart/items/$foodItemId',
    body: {'quantity': quantity},
  );

  Future<Map<String, dynamic>> removeCartItem(String foodItemId) =>
      _sendObject('DELETE', 'cart/items/$foodItemId');

  Future<Map<String, dynamic>> clearCart() => _sendObject('DELETE', 'cart');

  Future<Map<String, dynamic>> createOrder({required String deliveryAddress}) =>
      _postObject(
        'orders',
        body: {
          'deliveryAddress': deliveryAddress,
          'paymentMethod': 'cash_on_delivery',
        },
      );

  Future<List<dynamic>> getOrders() => _getList('orders');

  Future<Map<String, dynamic>> getOrder(String id) => _getObject('orders/$id');

  Future<Map<String, dynamic>> createConversation() =>
      _postObject('conversations', body: {});

  Future<List<dynamic>> getConversations() => _getList('conversations');

  Future<Map<String, dynamic>> getConversation(String id) =>
      _getObject('conversations/$id');

  Future<Map<String, dynamic>> sendConversationMessage({
    required String conversationId,
    required String message,
    bool isVoiceInput = false,
  }) => _postObject(
    'conversations/$conversationId/messages',
    body: {'message': message, 'isVoiceInput': isVoiceInput},
  );

  Future<Map<String, dynamic>> deleteConversation(String id) =>
      _sendObject('DELETE', 'conversations/$id');

  Future<bool> isHealthy() async {
    final response = await _get('health');
    return response['success'] == true;
  }

  Future<Map<String, dynamic>> _getObject(String path) async {
    final response = await _get(path);
    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw const FoodlyApiException(
        'The server returned an invalid object response.',
      );
    }
    return data;
  }

  Future<List<dynamic>> _getList(
    String path, {
    Map<String, String> queryParameters = const {},
  }) async {
    final response = await _get(path, queryParameters: queryParameters);
    final data = response['data'];
    if (data is! List<dynamic>) {
      throw const FoodlyApiException(
        'The server returned an invalid list response.',
      );
    }
    return data;
  }

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, String> queryParameters = const {},
  }) async {
    final baseUri = Uri.parse(FoodlyApiConfig.baseUrl);
    final uri = baseUri.replace(
      path: '${baseUri.path.replaceFirst(RegExp(r'/$'), '')}/$path',
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );

    final response = await _client.get(uri, headers: await _headers());
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> _postObject(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    return _sendObject('POST', path, body: body);
  }

  Future<Map<String, dynamic>> _sendObject(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final request = http.Request(method, _uri(path));
    request.headers.addAll(await _headers());
    if (body != null) request.body = jsonEncode(body);
    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);
    final parsed = _parseResponse(response);
    final data = parsed['data'];
    if (data is! Map<String, dynamic>) {
      throw const FoodlyApiException(
        'The server returned an invalid object response.',
      );
    }
    return data;
  }

  Uri _uri(String path, {Map<String, String> queryParameters = const {}}) {
    final baseUri = Uri.parse(FoodlyApiConfig.baseUrl);
    return baseUri.replace(
      path: '${baseUri.path.replaceFirst(RegExp(r'/$'), '')}/$path',
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
  }

  Future<Map<String, String>> _headers() async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final token = await _tokenProvider?.call();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Map<String, dynamic> _parseResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) {
      throw const FoodlyApiException(
        'The server returned an invalid response.',
      );
    }
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        body['success'] != true) {
      throw FoodlyApiException(
        body['message'] as String? ?? 'The server request failed.',
      );
    }
    return body;
  }
}
