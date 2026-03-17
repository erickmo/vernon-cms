import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/cms_user.dart';

/// Interface repository untuk user management.
///
/// Admin-only CRUD di `/api/v1/users`.
abstract class UserRepository {
  /// Ambil daftar user dengan pagination.
  Future<Either<Failure, List<CmsUser>>> getUsers({
    String? search,
    String? role,
    int page = 1,
    int limit = 20,
  });

  /// Ambil detail user berdasarkan [id].
  Future<Either<Failure, CmsUser>> getUserById(String id);

  /// Buat user baru.
  ///
  /// [passwordHash] dikirim sebagai `password_hash` ke API.
  Future<Either<Failure, void>> createUser(
    CmsUser user, {
    required String passwordHash,
  });

  /// Perbarui user yang sudah ada.
  Future<Either<Failure, void>> updateUser(CmsUser user);

  /// Hapus user berdasarkan [id].
  Future<Either<Failure, void>> deleteUser(String id);
}
