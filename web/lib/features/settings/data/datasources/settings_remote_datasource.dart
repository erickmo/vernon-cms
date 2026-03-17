import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../models/site_settings_model.dart';

/// Datasource remote untuk pengaturan situs.
abstract class SettingsRemoteDataSource {
  /// Ambil pengaturan situs saat ini.
  ///
  /// Throws [ServerException] jika gagal.
  Future<SiteSettingsModel> getSettings();

  /// Perbarui pengaturan situs.
  ///
  /// Throws [ServerException] jika gagal.
  Future<SiteSettingsModel> updateSettings(Map<String, dynamic> data);
}

/// Implementasi [SettingsRemoteDataSource] menggunakan Dio.
class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final ApiClient _apiClient;

  const SettingsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<SiteSettingsModel> getSettings() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/settings');
      return SiteSettingsModel.fromJson(
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
  Future<SiteSettingsModel> updateSettings(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put(
        '/api/v1/settings',
        data: data,
      );
      return SiteSettingsModel.fromJson(
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
