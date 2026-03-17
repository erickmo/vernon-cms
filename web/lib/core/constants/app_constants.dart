import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Konstanta aplikasi yang digunakan di seluruh project.
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Vernon CMS';
  static const String appVersion = '1.0.0';

  // API
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://localhost:8080';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';

  // Pagination
  static const int defaultPageSize = 20;
}
