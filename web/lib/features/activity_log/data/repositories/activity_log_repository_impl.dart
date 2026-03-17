import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../domain/entities/activity_log.dart';
import '../../domain/repositories/activity_log_repository.dart';
import '../datasources/activity_log_remote_datasource.dart';

/// Implementasi [ActivityLogRepository].
class ActivityLogRepositoryImpl implements ActivityLogRepository {
  final ActivityLogRemoteDataSource _remoteDataSource;

  const ActivityLogRepositoryImpl({
    required ActivityLogRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<ActivityLog>>> getActivityLogs({
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
      final response = await _remoteDataSource.getActivityLogs(
        search: search,
        action: action,
        entityType: entityType,
        userId: userId,
        dateFrom: dateFrom,
        dateTo: dateTo,
        page: page,
        perPage: perPage,
      );
      return Right(response.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }
}
