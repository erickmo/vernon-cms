import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../models/api_token_model.dart';

/// Datasource remote untuk API token.
abstract class ApiTokenRemoteDataSource {
  /// Ambil daftar API token.
  ///
  /// Throws [ServerException] jika gagal.
  Future<List<ApiTokenModel>> getTokens();

  /// Buat API token baru.
  ///
  /// Throws [ServerException] jika gagal.
  Future<ApiTokenModel> createToken(Map<String, dynamic> data);

  /// Perbarui API token.
  ///
  /// Throws [ServerException] jika gagal.
  Future<ApiTokenModel> updateToken(String id, Map<String, dynamic> data);

  /// Hapus API token.
  ///
  /// Throws [ServerException] jika gagal.
  Future<void> deleteToken(String id);

  /// Toggle status aktif API token.
  ///
  /// Throws [ServerException] jika gagal.
  Future<ApiTokenModel> toggleTokenActive(String id);
}

/// Implementasi [ApiTokenRemoteDataSource] menggunakan Dio.
class ApiTokenRemoteDataSourceImpl implements ApiTokenRemoteDataSource {
  final ApiClient _apiClient;

  const ApiTokenRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<ApiTokenModel>> getTokens() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/tokens');

      final list = response.data as List<dynamic>;
      return list
          .map((e) => ApiTokenModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<ApiTokenModel> createToken(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/tokens',
        data: data,
      );
      return ApiTokenModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<ApiTokenModel> updateToken(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.dio.put(
        '/api/v1/tokens/$id',
        data: data,
      );
      return ApiTokenModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> deleteToken(String id) async {
    try {
      await _apiClient.dio.delete('/api/v1/tokens/$id');
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<ApiTokenModel> toggleTokenActive(String id) async {
    try {
      final response = await _apiClient.dio.put(
        '/api/v1/tokens/$id/toggle-active',
      );
      return ApiTokenModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ??
          data['error'] as String? ??
          'Terjadi kesalahan pada server';
    }
    return e.message ?? 'Terjadi kesalahan pada server';
  }
}
