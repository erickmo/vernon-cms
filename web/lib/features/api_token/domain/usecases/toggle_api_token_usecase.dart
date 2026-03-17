import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/api_token.dart';
import '../repositories/api_token_repository.dart';

/// Use case untuk toggle status aktif API token.
class ToggleApiTokenUseCase {
  final ApiTokenRepository _repository;

  const ToggleApiTokenUseCase(this._repository);

  /// Returns [Right(ApiToken)] jika berhasil.
  Future<Either<Failure, ApiToken>> call(String id) {
    return _repository.toggleTokenActive(id);
  }
}
