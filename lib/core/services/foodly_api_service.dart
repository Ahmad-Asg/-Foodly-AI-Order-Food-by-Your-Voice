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
  FoodlyApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

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

  Future<bool> isHealthy() async {
    final response = await _get('health');
    return response['success'] == true;
  }

  Future<Map<String, dynamic>> _getObject(String path) async {
    final response = await _get(path);
    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw const FoodlyApiException('The server returned an invalid object response.');
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
      throw const FoodlyApiException('The server returned an invalid list response.');
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

    final response = await _client.get(uri);
    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) {
      throw const FoodlyApiException('The server returned an invalid response.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300 || body['success'] != true) {
      throw FoodlyApiException(body['message'] as String? ?? 'The server request failed.');
    }
    return body;
  }
}
