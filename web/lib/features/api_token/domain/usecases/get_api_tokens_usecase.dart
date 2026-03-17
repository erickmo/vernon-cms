import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/api_token.dart';
import '../repositories/api_token_repository.dart';

/// Use case untuk mengambil daftar API token.
class GetApiTokensUseCase {
  final ApiTokenRepository _repository;

  const GetApiTokensUseCase(this._repository);

  /// Returns [Right(List<ApiToken>)] jika berhasil.
  Future<Either<Failure, List<ApiToken>>> call() {
    return _repository.getTokens();
  }
}
