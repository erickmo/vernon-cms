import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/cms_user.dart';
import '../repositories/user_repository.dart';

/// Use case untuk mengambil detail user.
class GetUserDetailUseCase {
  final UserRepository _repository;

  const GetUserDetailUseCase(this._repository);

  /// Returns [Right(CmsUser)] jika berhasil.
  Future<Either<Failure, CmsUser>> call(String id) {
    return _repository.getUserById(id);
  }
}
