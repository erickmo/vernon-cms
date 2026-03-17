import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../models/activity_log_model.dart';

/// Datasource remote untuk log aktivitas.
abstract class ActivityLogRemoteDataSource {
  /// Ambil daftar log aktivitas.
  ///
  /// Throws [ServerException] jika gagal.
  Future<List<ActivityLogModel>> getActivityLogs({
    String? search,
    String? action,
    String? entityType,
    String? userId,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int perPage = 20,
  });
}

/// Implementasi [ActivityLogRemoteDataSource] menggunakan Dio.
class ActivityLogRemoteDataSourceImpl implements ActivityLogRemoteDataSource {
  final ApiClient _apiClient;

  const ActivityLogRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<ActivityLogModel>> getActivityLogs({
    String? search,
    String? action,
    String? entityType,
    String? userId,
    String? dateFrom,
    String? dateTo,
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
      if (action != null && action.isNotEmpty) {
        queryParameters['action'] = action;
      }
      if (entityType != null && entityType.isNotEmpty) {
        queryParameters['entity_type'] = entityType;
      }
      if (userId != null && userId.isNotEmpty) {
        queryParameters['user_id'] = userId;
      }
      if (dateFrom != null && dateFrom.isNotEmpty) {
        queryParameters['date_from'] = dateFrom;
      }
      if (dateTo != null && dateTo.isNotEmpty) {
        queryParameters['date_to'] = dateTo;
      }

      final response = await _apiClient.dio.get(
        '/api/v1/activity-logs',
        queryParameters: queryParameters,
      );

      final list = response.data as List<dynamic>;
      return list
          .map((e) => ActivityLogModel.fromJson(e as Map<String, dynamic>))
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
