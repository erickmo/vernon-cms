import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../models/domain_record_model.dart';
import '../models/record_option_model.dart';

/// Datasource remote untuk domain records.
abstract class DomainRecordsRemoteDataSource {
  /// Ambil daftar record untuk domain tertentu.
  ///
  /// Throws [ServerException] jika gagal.
  Future<List<DomainRecordModel>> getRecords({
    required String domainSlug,
    String? search,
    int page = 1,
    int perPage = 10,
  });

  /// Ambil detail record berdasarkan [id].
  ///
  /// Throws [ServerException] jika gagal.
  Future<DomainRecordModel> getRecordDetail({
    required String domainSlug,
    required String id,
  });

  /// Buat record baru.
  ///
  /// Throws [ServerException] jika gagal.
  Future<DomainRecordModel> createRecord({
    required String domainSlug,
    required Map<String, dynamic> data,
  });

  /// Perbarui record yang sudah ada.
  ///
  /// Throws [ServerException] jika gagal.
  Future<DomainRecordModel> updateRecord({
    required String domainSlug,
    required String id,
    required Map<String, dynamic> data,
  });

  /// Hapus record berdasarkan [id].
  ///
  /// Throws [ServerException] jika gagal.
  Future<void> deleteRecord({
    required String domainSlug,
    required String id,
  });

  /// Ambil daftar opsi record untuk relation dropdown.
  ///
  /// Throws [ServerException] jika gagal.
  Future<List<RecordOptionModel>> getRecordOptions({
    required String domainSlug,
  });
}

/// Implementasi [DomainRecordsRemoteDataSource] menggunakan Dio.
class DomainRecordsRemoteDataSourceImpl
    implements DomainRecordsRemoteDataSource {
  final ApiClient _apiClient;

  const DomainRecordsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<DomainRecordModel>> getRecords({
    required String domainSlug,
    String? search,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };
      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }

      final response = await _apiClient.dio.get(
        '/api/v1/domains/$domainSlug/records',
        queryParameters: queryParameters,
      );

      final list = response.data as List<dynamic>;
      return list
          .map((e) => DomainRecordModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<DomainRecordModel> getRecordDetail({
    required String domainSlug,
    required String id,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/domains/$domainSlug/records/$id',
      );
      return DomainRecordModel.fromJson(
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
  Future<DomainRecordModel> createRecord({
    required String domainSlug,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/domains/$domainSlug/records',
        data: {'data': data},
      );
      return DomainRecordModel.fromJson(
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
  Future<DomainRecordModel> updateRecord({
    required String domainSlug,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        '/api/v1/domains/$domainSlug/records/$id',
        data: {'data': data},
      );
      return DomainRecordModel.fromJson(
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
  Future<void> deleteRecord({
    required String domainSlug,
    required String id,
  }) async {
    try {
      await _apiClient.dio.delete('/api/v1/domains/$domainSlug/records/$id');
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<RecordOptionModel>> getRecordOptions({
    required String domainSlug,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/domains/$domainSlug/records/options',
      );

      final list = response.data as List<dynamic>;
      return list
          .map((e) => RecordOptionModel.fromJson(e as Map<String, dynamic>))
          .toList();
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
