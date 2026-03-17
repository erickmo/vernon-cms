import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/site_settings.dart';

/// Interface repository untuk pengaturan situs.
abstract class SettingsRepository {
  /// Ambil pengaturan situs saat ini.
  Future<Either<Failure, SiteSettings>> getSettings();

  /// Perbarui pengaturan situs.
  Future<Either<Failure, SiteSettings>> updateSettings(
    SiteSettings settings,
  );
}
