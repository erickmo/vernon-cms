import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../models/cms_user_model.dart';

/// Datasource remote untuk user management.
///
/// API: `/api/v1/users` (admin only).
/// Response wrapped: `{ "data": { ... } }`, list: `{ "data": { "items": [...], "total", "page", "limit" } }`.
abstract class UserRemoteDataSource {
  /// Ambil daftar user dengan pagination.
  ///
  /// Throws [ServerException] jika gagal.
  Future<List<CmsUserModel>> getUsers({
    String? search,
    String? role,
    int page = 1,
    int limit = 20,
  });

  /// Ambil detail user berdasarkan [id].
  ///
  /// Throws [ServerException] jika gagal.
  Future<CmsUserModel> getUserById(String id);

  /// Buat user baru.
  ///
  /// [data] berisi: email, password_hash, name, role.
  /// Throws [ServerException] jika gagal.
  Future<void> createUser(Map<String, dynamic> data);

  /// Perbarui user yang sudah ada.
  ///
  /// [data] berisi: email, name, role (dan opsional is_active).
  /// Throws [ServerException] jika gagal.
  Future<void> updateUser(String id, Map<String, dynamic> data);

  /// Hapus user berdasarkan [id].
  ///
  /// Throws [ServerException] jika gagal.
  Future<void> deleteUser(String id);
}

/// Implementasi [UserRemoteDataSource] menggunakan Dio.
class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final ApiClient _apiClient;

  const UserRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<CmsUserModel>> getUsers({
    String? search,
    String? role,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }
      if (role != null && role.isNotEmpty) {
        queryParameters['role'] = role;
      }

      final response = await _apiClient.dio.get(
        '/api/v1/users',
        queryParameters: queryParameters,
      );

      final data = response.data['data'] as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>;
      return items
          .map((e) => CmsUserModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<CmsUserModel> getUserById(String id) async {
    try {
      final response = await _apiClient.dio.get('/api/v1/users/$id');
      final data = response.data['data'] as Map<String, dynamic>;
      return CmsUserModel.fromJson(data);
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> createUser(Map<String, dynamic> data) async {
    try {
      await _apiClient.dio.post(
        '/api/v1/users',
        data: data,
      );
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> updateUser(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      await _apiClient.dio.put(
        '/api/v1/users/$id',
        data: data,
      );
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    try {
      await _apiClient.dio.delete('/api/v1/users/$id');
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
      return data['error'] as String? ??
          data['message'] as String? ??
          'Terjadi kesalahan pada server';
    }
    return e.message ?? 'Terjadi kesalahan pada server';
  }
}
