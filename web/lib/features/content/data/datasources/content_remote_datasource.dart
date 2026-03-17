import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/paginated_response.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../models/content_model.dart';

/// Datasource remote untuk konten.
abstract class ContentRemoteDataSource {
  /// Ambil daftar konten dengan pagination.
  ///
  /// Throws [ServerException] jika gagal.
  Future<PaginatedResponse<ContentModel>> getContents({
    String? search,
    String? status,
    int page = 1,
    int limit = 20,
  });

  /// Ambil detail konten berdasarkan [id].
  ///
  /// Throws [ServerException] jika gagal.
  Future<ContentModel> getContentById(String id);

  /// Ambil konten berdasarkan [slug].
  ///
  /// Throws [ServerException] jika gagal.
  Future<ContentModel> getContentBySlug(String slug);

  /// Buat konten baru.
  ///
  /// Throws [ServerException] jika gagal.
  Future<void> createContent(Map<String, dynamic> data);

  /// Perbarui konten yang sudah ada.
  ///
  /// Throws [ServerException] jika gagal.
  Future<void> updateContent(String id, Map<String, dynamic> data);

  /// Publikasikan konten (draft -> published).
  ///
  /// Throws [ServerException] jika gagal.
  Future<void> publishContent(String id);

  /// Hapus konten berdasarkan [id].
  ///
  /// Throws [ServerException] jika gagal.
  Future<void> deleteContent(String id);
}

/// Implementasi [ContentRemoteDataSource] menggunakan Dio.
class ContentRemoteDataSourceImpl implements ContentRemoteDataSource {
  final ApiClient _apiClient;

  const ContentRemoteDataSourceImpl(this._apiClient);

  @override
  Future<PaginatedResponse<ContentModel>> getContents({
    String? search,
    String? status,
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
      if (status != null && status.isNotEmpty) {
        queryParameters['status'] = status;
      }

      final response = await _apiClient.dio.get(
        '/api/v1/contents',
        queryParameters: queryParameters,
      );

      final data = response.data['data'] as Map<String, dynamic>;
      return PaginatedResponse.fromJson(data, ContentModel.fromJson);
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<ContentModel> getContentById(String id) async {
    try {
      final response = await _apiClient.dio.get('/api/v1/contents/$id');
      final data = response.data['data'] as Map<String, dynamic>;
      return ContentModel.fromJson(data);
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<ContentModel> getContentBySlug(String slug) async {
    try {
      final response = await _apiClient.dio.get('/api/v1/contents/slug/$slug');
      final data = response.data['data'] as Map<String, dynamic>;
      return ContentModel.fromJson(data);
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> createContent(Map<String, dynamic> data) async {
    try {
      await _apiClient.dio.post(
        '/api/v1/contents',
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
  Future<void> updateContent(String id, Map<String, dynamic> data) async {
    try {
      await _apiClient.dio.put(
        '/api/v1/contents/$id',
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
  Future<void> publishContent(String id) async {
    try {
      await _apiClient.dio.put('/api/v1/contents/$id/publish');
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> deleteContent(String id) async {
    try {
      await _apiClient.dio.delete('/api/v1/contents/$id');
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
