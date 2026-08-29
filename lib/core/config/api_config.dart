class FoodlyApiConfig {
  const FoodlyApiConfig._();

  /// Pass FOODLY_API_BASE_URL when running on a physical phone, for example:
  /// --dart-define=FOODLY_API_BASE_URL=http://192.168.1.10:5000/api
  static const baseUrl = String.fromEnvironment(
    'FOODLY_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000/api',
  );
}
