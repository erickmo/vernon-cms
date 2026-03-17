import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../models/daily_content_model.dart';
import '../models/dashboard_stats_model.dart';

/// Datasource remote untuk data dashboard.
abstract class DashboardRemoteDataSource {
  /// Ambil statistik dashboard.
  ///
  /// Throws [ServerException] jika gagal.
  Future<DashboardStatsModel> getStats();

  /// Ambil data konten per hari.
  ///
  /// Throws [ServerException] jika gagal.
  Future<List<DailyContentModel>> getDailyContent(int days);
}

/// Implementasi [DashboardRemoteDataSource] menggunakan Dio.
class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiClient _apiClient;

  const DashboardRemoteDataSourceImpl(this._apiClient);

  @override
  Future<DashboardStatsModel> getStats() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/dashboard/stats');
      return DashboardStatsModel.fromJson(
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
  Future<List<DailyContentModel>> getDailyContent(int days) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/dashboard/daily-content',
        queryParameters: {'days': days},
      );
      final list = response.data as List<dynamic>;
      return list
          .map((e) => DailyContentModel.fromJson(e as Map<String, dynamic>))
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
