import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/daily_content.dart';
import '../entities/dashboard_stats.dart';

/// Interface repository untuk dashboard.
abstract class DashboardRepository {
  /// Ambil statistik dashboard.
  Future<Either<Failure, DashboardStats>> getStats();

  /// Ambil data konten per hari untuk chart.
  Future<Either<Failure, List<DailyContent>>> getDailyContent({int days = 7});
}
