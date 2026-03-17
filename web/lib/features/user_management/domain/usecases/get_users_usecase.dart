import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/cms_user.dart';
import '../repositories/user_repository.dart';

/// Use case untuk mengambil daftar user.
class GetUsersUseCase {
  final UserRepository _repository;

  const GetUsersUseCase(this._repository);

  /// Returns [Right(List<CmsUser>)] jika berhasil.
  Future<Either<Failure, List<CmsUser>>> call({
    String? search,
    String? role,
    int page = 1,
    int limit = 20,
  }) {
    return _repository.getUsers(
      search: search,
      role: role,
      page: page,
      limit: limit,
    );
  }
}
