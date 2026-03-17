import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/api_token.dart';
import '../repositories/api_token_repository.dart';

/// Use case untuk membuat API token baru.
class CreateApiTokenUseCase {
  final ApiTokenRepository _repository;

  const CreateApiTokenUseCase(this._repository);

  /// Returns [Right(ApiToken)] jika berhasil (dengan full token).
  Future<Either<Failure, ApiToken>> call(ApiToken token) {
    return _repository.createToken(token);
  }
}
