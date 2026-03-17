import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class ApiClient {
  late final Dio _dio;
  final SharedPreferences _prefs;

  ApiClient(this._prefs) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(_prefs),
      _TokenRefreshInterceptor(_dio, _prefs),
      _ErrorInterceptor(),
      PrettyDioLogger(
        requestHeader: false,
        requestBody: true,
        responseBody: true,
        compact: true,
      ),
    ]);
  }

  Dio get dio => _dio;
}

class _AuthInterceptor extends Interceptor {
  final SharedPreferences _prefs;

  _AuthInterceptor(this._prefs);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _prefs.getString(AppConstants.accessTokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

class _TokenRefreshInterceptor extends Interceptor {
  final Dio _dio;
  final SharedPreferences _prefs;

  _TokenRefreshInterceptor(this._dio, this._prefs);

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isAuthEndpoint =
        err.requestOptions.path.contains('/auth/');
    if (err.response?.statusCode == 401 && !isAuthEndpoint) {
      final refreshToken = _prefs.getString(AppConstants.refreshTokenKey);
      if (refreshToken != null) {
        try {
          final response = await _dio.post(
            '/api/v1/auth/refresh',
            data: {'refresh_token': refreshToken},
          );
          final newToken = response.data['data']['access_token'] as String;
          await _prefs.setString(AppConstants.accessTokenKey, newToken);
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final retryResponse = await _dio.fetch(err.requestOptions);
          return handler.resolve(retryResponse);
        } catch (_) {
          await _prefs.remove(AppConstants.accessTokenKey);
          await _prefs.remove(AppConstants.refreshTokenKey);
        }
      }
    }
    handler.next(err);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final data = err.response?.data;
    if (data is Map<String, dynamic> && data.containsKey('error')) {
      handler.next(
        err.copyWith(
          message: data['error']?.toString() ?? err.message,
        ),
      );
      return;
    }
    handler.next(err);
  }
}
