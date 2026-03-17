import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/api_token_repository.dart';

/// Use case untuk menghapus (mencabut) API token.
class DeleteApiTokenUseCase {
  final ApiTokenRepository _repository;

  const DeleteApiTokenUseCase(this._repository);

  /// Returns [Right(void)] jika berhasil.
  Future<Either<Failure, void>> call(String id) {
    return _repository.deleteToken(id);
  }
}
