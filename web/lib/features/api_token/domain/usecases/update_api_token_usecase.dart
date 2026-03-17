import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/api_token.dart';
import '../repositories/api_token_repository.dart';

/// Use case untuk memperbarui API token.
class UpdateApiTokenUseCase {
  final ApiTokenRepository _repository;

  const UpdateApiTokenUseCase(this._repository);

  /// Returns [Right(ApiToken)] jika berhasil.
  Future<Either<Failure, ApiToken>> call(ApiToken token) {
    return _repository.updateToken(token);
  }
}
