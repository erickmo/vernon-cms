import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/api_token.dart';

/// Interface repository untuk API token.
abstract class ApiTokenRepository {
  /// Ambil daftar API token.
  Future<Either<Failure, List<ApiToken>>> getTokens();

  /// Buat API token baru.
  Future<Either<Failure, ApiToken>> createToken(ApiToken token);

  /// Perbarui API token.
  Future<Either<Failure, ApiToken>> updateToken(ApiToken token);

  /// Hapus API token.
  Future<Either<Failure, void>> deleteToken(String id);

  /// Toggle status aktif API token.
  Future<Either<Failure, ApiToken>> toggleTokenActive(String id);
}
