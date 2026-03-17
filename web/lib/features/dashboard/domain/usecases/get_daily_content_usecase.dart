import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/daily_content.dart';
import '../repositories/dashboard_repository.dart';

/// Use case untuk mengambil data konten per hari.
class GetDailyContentUseCase {
  final DashboardRepository _repository;

  const GetDailyContentUseCase(this._repository);

  /// Returns [Right(List<DailyContent>)] data 7 hari terakhir.
  Future<Either<Failure, List<DailyContent>>> call({int days = 7}) {
    return _repository.getDailyContent(days: days);
  }
}
