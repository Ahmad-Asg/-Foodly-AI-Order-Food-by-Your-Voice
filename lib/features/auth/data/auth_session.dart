import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/services/foodly_api_service.dart';

class AuthUser {
  const AuthUser({required this.id, required this.name, required this.email});

  final String id;
  final String name;
  final String email;

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
  );
}

class AuthSession {
  AuthSession({FlutterSecureStorage? storage, FoodlyApiService? api})
      : _storage = storage ?? const FlutterSecureStorage(),
        _api = api ?? FoodlyApiService(
          tokenProvider: () => (storage ?? const FlutterSecureStorage()).read(key: _tokenKey),
        );

  static const _tokenKey = 'foodly_auth_token';
  final FlutterSecureStorage _storage;
  final FoodlyApiService _api;

  Future<AuthUser?> restoreSession() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null || token.isEmpty) return null;

    try {
      return AuthUser.fromJson(await _api.getCurrentUser());
    } on FoodlyApiException {
      await logout();
      return null;
    }
  }

  Future<AuthUser> login({required String email, required String password}) async {
    final data = await _api.login(email: email, password: password);
    return _saveAuthResponse(data);
  }

  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final data = await _api.register(name: name, email: email, password: password);
    return _saveAuthResponse(data);
  }

  Future<void> logout() => _storage.delete(key: _tokenKey);

  Future<AuthUser> _saveAuthResponse(Map<String, dynamic> data) async {
    final token = data['token'];
    final user = data['user'];
    if (token is! String || user is! Map<String, dynamic>) {
      throw const FoodlyApiException('The server returned incomplete login information.');
    }
    await _storage.write(key: _tokenKey, value: token);
    return AuthUser.fromJson(user);
  }
}
