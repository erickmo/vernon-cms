import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/register_request_model.dart';

/// Exception khusus untuk error dari server.
class ServerException implements Exception {
  /// Pesan error dari server.
  final String message;

  /// HTTP status code.
  final int? statusCode;

  const ServerException(this.message, {this.statusCode});
}

/// Datasource remote untuk autentikasi.
abstract class AuthRemoteDataSource {
  /// Melakukan login ke server.
  ///
  /// Throws [ServerException] jika gagal.
  Future<LoginResponseModel> login(LoginRequestModel request);

  /// Melakukan register user baru ke server.
  ///
  /// Throws [ServerException] jika gagal.
  Future<void> register(RegisterRequestModel request);
}

/// Implementasi [AuthRemoteDataSource] menggunakan Dio.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  const AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/auth/login',
        data: request.toJson(),
      );

      final data = ApiResponse.extractData<Map<String, dynamic>>(
        response.data,
      );
      return LoginResponseModel.fromJson(data);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final message = _extractErrorMessage(e);
      throw ServerException(message, statusCode: statusCode);
    }
  }

  @override
  Future<void> register(RegisterRequestModel request) async {
    try {
      await _apiClient.dio.post(
        '/api/v1/auth/register',
        data: request.toJson(),
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final message = _extractErrorMessage(e);
      throw ServerException(message, statusCode: statusCode);
    }
  }

  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data != null) {
      return ApiResponse.extractError(data);
    }
    return e.message ?? 'Terjadi kesalahan pada server';
  }
}
