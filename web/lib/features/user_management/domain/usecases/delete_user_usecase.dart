import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/user_repository.dart';

/// Use case untuk menghapus user (soft delete).
class DeleteUserUseCase {
  final UserRepository _repository;

  const DeleteUserUseCase(this._repository);

  /// Returns [Right(void)] jika berhasil.
  Future<Either<Failure, void>> call(String id) {
    return _repository.deleteUser(id);
  }
}
