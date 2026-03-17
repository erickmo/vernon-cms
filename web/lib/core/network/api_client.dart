import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import 'api_response.dart';

/// HTTP client standar menggunakan Dio.
/// Sudah termasuk: auth interceptor, token refresh interceptor,
/// error interceptor, dan logger.
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

/// Interceptor untuk menambahkan JWT token ke setiap request.
class _AuthInterceptor extends Interceptor {
  final SharedPreferences _prefs;

  _AuthInterceptor(this._prefs);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final token = _prefs.getString(AppConstants.accessTokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

/// Interceptor untuk melakukan token refresh saat menerima 401.
///
/// Ketika server merespons 401, interceptor ini mencoba refresh token
/// menggunakan POST `/api/v1/auth/refresh`. Jika berhasil, token baru
/// disimpan dan request asli diulangi. Jika gagal, error diteruskan
/// (UI harus redirect ke login).
class _TokenRefreshInterceptor extends Interceptor {
  final Dio _dio;
  final SharedPreferences _prefs;
  bool _isRefreshing = false;

  _TokenRefreshInterceptor(this._dio, this._prefs);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401 || _isRefreshing) {
      return handler.next(err);
    }

    // Jangan refresh untuk request ke endpoint auth
    final path = err.requestOptions.path;
    if (path.contains('/api/v1/auth/')) {
      return handler.next(err);
    }

    final refreshToken = _prefs.getString(AppConstants.refreshTokenKey);
    if (refreshToken == null) {
      return handler.next(err);
    }

    _isRefreshing = true;
    try {
      // Buat Dio baru tanpa interceptor untuk menghindari loop
      final refreshDio = Dio(BaseOptions(
        baseUrl: _dio.options.baseUrl,
        headers: {'Content-Type': 'application/json'},
      ));

      final response = await refreshDio.post(
        '/api/v1/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final data = ApiResponse.extractData<Map<String, dynamic>>(
        response.data,
      );
      final newAccessToken = data['access_token'] as String;
      final newRefreshToken = data['refresh_token'] as String;

      // Simpan token baru
      await _prefs.setString(AppConstants.accessTokenKey, newAccessToken);
      await _prefs.setString(AppConstants.refreshTokenKey, newRefreshToken);

      // Retry request asli dengan token baru
      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer $newAccessToken';

      final retryResponse = await _dio.fetch(opts);
      return handler.resolve(retryResponse);
    } on DioException {
      // Refresh gagal — hapus token, biarkan error 401 diteruskan
      await _prefs.remove(AppConstants.accessTokenKey);
      await _prefs.remove(AppConstants.refreshTokenKey);
      return handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }
}

/// Interceptor untuk menangani error response secara konsisten.
///
/// Mengurai format error API `{ "error": "..." }` dan membuat
/// DioException dengan pesan yang sesuai.
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final data = err.response?.data;
    if (data != null) {
      final errorMessage = ApiResponse.extractError(data);
      handler.next(
        DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          type: err.type,
          error: errorMessage,
          message: errorMessage,
        ),
      );
    } else {
      handler.next(err);
    }
  }
}
