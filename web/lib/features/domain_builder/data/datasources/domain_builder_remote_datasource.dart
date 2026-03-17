import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../models/domain_definition_model.dart';

/// Datasource remote untuk domain builder.
abstract class DomainBuilderRemoteDataSource {
  /// Ambil daftar semua domain.
  ///
  /// Throws [ServerException] jika gagal.
  Future<List<DomainDefinitionModel>> getDomains();

  /// Ambil detail domain berdasarkan [id].
  ///
  /// Throws [ServerException] jika gagal.
  Future<DomainDefinitionModel> getDomainDetail(String id);

  /// Buat domain baru.
  ///
  /// Throws [ServerException] jika gagal.
  Future<DomainDefinitionModel> createDomain(Map<String, dynamic> data);

  /// Perbarui domain yang sudah ada.
  ///
  /// Throws [ServerException] jika gagal.
  Future<DomainDefinitionModel> updateDomain(
    String id,
    Map<String, dynamic> data,
  );

  /// Hapus domain berdasarkan [id].
  ///
  /// Throws [ServerException] jika gagal.
  Future<void> deleteDomain(String id);
}

/// Implementasi [DomainBuilderRemoteDataSource] menggunakan Dio.
class DomainBuilderRemoteDataSourceImpl
    implements DomainBuilderRemoteDataSource {
  final ApiClient _apiClient;

  const DomainBuilderRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<DomainDefinitionModel>> getDomains() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/domains');

      final raw = response.data;
      final List<dynamic> list;
      if (raw is List) {
        list = raw;
      } else if (raw is Map<String, dynamic> && raw['data'] is List) {
        list = raw['data'] as List<dynamic>;
      } else {
        list = [];
      }
      return list
          .map((e) =>
              DomainDefinitionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<DomainDefinitionModel> getDomainDetail(String id) async {
    try {
      final response = await _apiClient.dio.get('/api/v1/domains/$id');
      final raw = response.data;
      final Map<String, dynamic> json;
      if (raw is Map<String, dynamic> && raw['data'] is Map<String, dynamic>) {
        json = raw['data'] as Map<String, dynamic>;
      } else {
        json = raw as Map<String, dynamic>;
      }
      return DomainDefinitionModel.fromJson(json);
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<DomainDefinitionModel> createDomain(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/domains',
        data: data,
      );
      final raw = response.data;
      final Map<String, dynamic> json;
      if (raw is Map<String, dynamic> && raw['data'] is Map<String, dynamic>) {
        json = raw['data'] as Map<String, dynamic>;
      } else {
        json = raw as Map<String, dynamic>;
      }
      return DomainDefinitionModel.fromJson(json);
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<DomainDefinitionModel> updateDomain(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.dio.put(
        '/api/v1/domains/$id',
        data: data,
      );
      final raw = response.data;
      final Map<String, dynamic> json;
      if (raw is Map<String, dynamic> && raw['data'] is Map<String, dynamic>) {
        json = raw['data'] as Map<String, dynamic>;
      } else {
        json = raw as Map<String, dynamic>;
      }
      return DomainDefinitionModel.fromJson(json);
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> deleteDomain(String id) async {
    try {
      await _apiClient.dio.delete('/api/v1/domains/$id');
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
