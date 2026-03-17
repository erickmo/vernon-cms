import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/paginated_response.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../models/content_category_model.dart';

/// Datasource remote untuk kategori konten.
abstract class ContentCategoryRemoteDataSource {
  /// Ambil daftar kategori konten dengan pagination.
  ///
  /// Throws [ServerException] jika gagal.
  Future<PaginatedResponse<ContentCategoryModel>> getCategories({
    int page = 1,
    int limit = 20,
  });

  /// Ambil detail kategori berdasarkan [id].
  ///
  /// Throws [ServerException] jika gagal.
  Future<ContentCategoryModel> getCategoryById(String id);

  /// Buat kategori baru.
  ///
  /// Throws [ServerException] jika gagal.
  Future<void> createCategory(Map<String, dynamic> data);

  /// Perbarui kategori yang sudah ada.
  ///
  /// Throws [ServerException] jika gagal.
  Future<void> updateCategory(String id, Map<String, dynamic> data);

  /// Hapus kategori berdasarkan [id].
  ///
  /// Throws [ServerException] jika gagal.
  Future<void> deleteCategory(String id);
}

/// Implementasi [ContentCategoryRemoteDataSource] menggunakan Dio.
class ContentCategoryRemoteDataSourceImpl
    implements ContentCategoryRemoteDataSource {
  final ApiClient _apiClient;

  const ContentCategoryRemoteDataSourceImpl(this._apiClient);

  @override
  Future<PaginatedResponse<ContentCategoryModel>> getCategories({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      final response = await _apiClient.dio.get(
        '/api/v1/content-categories',
        queryParameters: queryParameters,
      );

      final data = response.data['data'] as Map<String, dynamic>;
      return PaginatedResponse.fromJson(data, ContentCategoryModel.fromJson);
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<ContentCategoryModel> getCategoryById(String id) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/content-categories/$id',
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return ContentCategoryModel.fromJson(data);
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> createCategory(Map<String, dynamic> data) async {
    try {
      await _apiClient.dio.post(
        '/api/v1/content-categories',
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
  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    try {
      await _apiClient.dio.put(
        '/api/v1/content-categories/$id',
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
  Future<void> deleteCategory(String id) async {
    try {
      await _apiClient.dio.delete('/api/v1/content-categories/$id');
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
