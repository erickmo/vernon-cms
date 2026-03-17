import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/paginated_response.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../models/page_model.dart';

/// Datasource remote untuk halaman CMS.
abstract class PageRemoteDataSource {
  /// Ambil daftar halaman dengan pagination.
  ///
  /// Throws [ServerException] jika gagal.
  Future<PaginatedResponse<PageModel>> getPages({
    String? search,
    int page = 1,
    int limit = 20,
  });

  /// Ambil detail halaman berdasarkan [id].
  ///
  /// Throws [ServerException] jika gagal.
  Future<PageModel> getPageById(String id);

  /// Buat halaman baru.
  ///
  /// Throws [ServerException] jika gagal.
  Future<void> createPage(Map<String, dynamic> data);

  /// Perbarui halaman yang sudah ada.
  ///
  /// Throws [ServerException] jika gagal.
  Future<void> updatePage(String id, Map<String, dynamic> data);

  /// Hapus halaman berdasarkan [id].
  ///
  /// Throws [ServerException] jika gagal.
  Future<void> deletePage(String id);
}

/// Implementasi [PageRemoteDataSource] menggunakan Dio.
class PageRemoteDataSourceImpl implements PageRemoteDataSource {
  final ApiClient _apiClient;

  const PageRemoteDataSourceImpl(this._apiClient);

  @override
  Future<PaginatedResponse<PageModel>> getPages({
    String? search,
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

      final response = await _apiClient.dio.get(
        '/api/v1/pages',
        queryParameters: queryParameters,
      );

      final data = response.data['data'] as Map<String, dynamic>;
      return PaginatedResponse.fromJson(data, PageModel.fromJson);
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<PageModel> getPageById(String id) async {
    try {
      final response = await _apiClient.dio.get('/api/v1/pages/$id');
      final data = response.data['data'] as Map<String, dynamic>;
      return PageModel.fromJson(data);
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> createPage(Map<String, dynamic> data) async {
    try {
      await _apiClient.dio.post(
        '/api/v1/pages',
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
  Future<void> updatePage(String id, Map<String, dynamic> data) async {
    try {
      await _apiClient.dio.put(
        '/api/v1/pages/$id',
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
  Future<void> deletePage(String id) async {
    try {
      await _apiClient.dio.delete('/api/v1/pages/$id');
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
