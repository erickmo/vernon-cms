import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/activity_log.dart';
import '../repositories/activity_log_repository.dart';

/// Use case untuk mengambil daftar log aktivitas.
class GetActivityLogsUseCase {
  final ActivityLogRepository _repository;

  const GetActivityLogsUseCase(this._repository);

  /// Returns [Right(List<ActivityLog>)] jika berhasil.
  Future<Either<Failure, List<ActivityLog>>> call({
    String? search,
    String? action,
    String? entityType,
    String? userId,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int perPage = 20,
  }) {
    return _repository.getActivityLogs(
      search: search,
      action: action,
      entityType: entityType,
      userId: userId,
      dateFrom: dateFrom,
      dateTo: dateTo,
      page: page,
      perPage: perPage,
    );
  }
}
