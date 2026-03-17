import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/activity_log.dart';

/// Interface repository untuk log aktivitas.
abstract class ActivityLogRepository {
  /// Ambil daftar log aktivitas.
  Future<Either<Failure, List<ActivityLog>>> getActivityLogs({
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
