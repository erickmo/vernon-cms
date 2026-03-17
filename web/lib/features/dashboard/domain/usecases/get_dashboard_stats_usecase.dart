import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/dashboard_stats.dart';
import '../repositories/dashboard_repository.dart';

/// Use case untuk mengambil statistik dashboard.
class GetDashboardStatsUseCase {
  final DashboardRepository _repository;

  const GetDashboardStatsUseCase(this._repository);

  /// Returns [Right(DashboardStats)] jika berhasil.
  Future<Either<Failure, DashboardStats>> call() {
    return _repository.getStats();
  }
}
