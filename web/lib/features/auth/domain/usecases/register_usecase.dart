import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/register_params.dart';
import '../repositories/auth_repository.dart';

/// Use case untuk melakukan registrasi user baru.
class RegisterUseCase {
  final AuthRepository _repository;

  const RegisterUseCase(this._repository);

  /// Melakukan registrasi user baru.
  ///
  /// Returns [Right(void)] jika berhasil.
  /// Returns [Left(Failure)] jika gagal.
  Future<Either<Failure, void>> call(RegisterParams params) {
    return _repository.register(params);
  }
}
