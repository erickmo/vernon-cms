import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/cms_user.dart';
import '../repositories/user_repository.dart';

/// Use case untuk membuat user baru.
class CreateUserUseCase {
  final UserRepository _repository;

  const CreateUserUseCase(this._repository);

  /// Returns [Right(void)] jika berhasil.
  Future<Either<Failure, void>> call(
    CmsUser user, {
    required String passwordHash,
  }) {
    return _repository.createUser(user, passwordHash: passwordHash);
  }
}
