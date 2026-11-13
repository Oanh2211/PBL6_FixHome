class ApiConstants {
  ApiConstants._();

  // Base URL của backend
  static const String baseUrl =
      'https://fixhome-api-gateway.onrender.com/api/v1';

  // Timeout
  static const Duration connectTimeout = Duration(seconds: 30);

  static const Duration receiveTimeout = Duration(seconds: 1200);
}
