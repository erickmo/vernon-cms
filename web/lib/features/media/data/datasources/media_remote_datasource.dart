import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../models/media_file_model.dart';

/// Datasource remote untuk media.
abstract class MediaRemoteDataSource {
  /// Ambil daftar file media.
  ///
  /// Throws [ServerException] jika gagal.
  Future<List<MediaFileModel>> getMediaList({
    String? search,
    String? mimeType,
    String? folder,
    int page = 1,
    int perPage = 20,
  });

  /// Ambil detail file media berdasarkan [id].
  ///
  /// Throws [ServerException] jika gagal.
  Future<MediaFileModel> getMediaDetail(String id);

  /// Upload file media baru.
  ///
  /// Throws [ServerException] jika gagal.
  Future<MediaFileModel> uploadMedia(Map<String, dynamic> data);

  /// Update metadata file media.
  ///
  /// Throws [ServerException] jika gagal.
  Future<MediaFileModel> updateMedia(String id, Map<String, dynamic> data);

  /// Hapus file media berdasarkan [id].
  ///
  /// Throws [ServerException] jika gagal.
  Future<void> deleteMedia(String id);

  /// Ambil daftar folder unik.
  ///
  /// Throws [ServerException] jika gagal.
  Future<List<String>> getMediaFolders();
}

/// Implementasi [MediaRemoteDataSource] menggunakan Dio.
class MediaRemoteDataSourceImpl implements MediaRemoteDataSource {
  final ApiClient _apiClient;

  const MediaRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<MediaFileModel>> getMediaList({
    String? search,
    String? mimeType,
    String? folder,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };
      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }
      if (mimeType != null && mimeType.isNotEmpty) {
        queryParameters['mime_type'] = mimeType;
      }
      if (folder != null && folder.isNotEmpty) {
        queryParameters['folder'] = folder;
      }

      final response = await _apiClient.dio.get(
        '/api/v1/media',
        queryParameters: queryParameters,
      );

      final list = response.data as List<dynamic>;
      return list
          .map((e) => MediaFileModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<MediaFileModel> getMediaDetail(String id) async {
    try {
      final response = await _apiClient.dio.get('/api/v1/media/$id');
      return MediaFileModel.fromJson(
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
  Future<MediaFileModel> uploadMedia(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/media/upload',
        data: data,
      );
      return MediaFileModel.fromJson(
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
  Future<MediaFileModel> updateMedia(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.dio.put(
        '/api/v1/media/$id',
        data: data,
      );
      return MediaFileModel.fromJson(
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
  Future<void> deleteMedia(String id) async {
    try {
      await _apiClient.dio.delete('/api/v1/media/$id');
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<String>> getMediaFolders() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/media/folders');
      final list = response.data as List<dynamic>;
      return list.map((e) => e as String).toList();
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
