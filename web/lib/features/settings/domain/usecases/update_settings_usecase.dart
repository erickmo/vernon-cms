import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/site_settings.dart';
import '../repositories/settings_repository.dart';

/// Use case untuk memperbarui pengaturan situs.
class UpdateSettingsUseCase {
  final SettingsRepository _repository;

  const UpdateSettingsUseCase(this._repository);

  /// Returns [Right(SiteSettings)] jika berhasil.
  Future<Either<Failure, SiteSettings>> call(SiteSettings settings) {
    return _repository.updateSettings(settings);
  }
}
