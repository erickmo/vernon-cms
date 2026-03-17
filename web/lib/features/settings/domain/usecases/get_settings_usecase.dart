import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/site_settings.dart';
import '../repositories/settings_repository.dart';

/// Use case untuk mengambil pengaturan situs.
class GetSettingsUseCase {
  final SettingsRepository _repository;

  const GetSettingsUseCase(this._repository);

  /// Returns [Right(SiteSettings)] jika berhasil.
  Future<Either<Failure, SiteSettings>> call() {
    return _repository.getSettings();
  }
}
