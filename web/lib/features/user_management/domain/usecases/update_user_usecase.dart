import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/cms_user.dart';
import '../repositories/user_repository.dart';

/// Use case untuk memperbarui user.
class UpdateUserUseCase {
  final UserRepository _repository;

  const UpdateUserUseCase(this._repository);

  /// Returns [Right(void)] jika berhasil.
  Future<Either<Failure, void>> call(CmsUser user) {
    return _repository.updateUser(user);
  }
}
