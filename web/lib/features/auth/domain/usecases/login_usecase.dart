import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/auth_token.dart';
import '../entities/login_params.dart';
import '../repositories/auth_repository.dart';

/// Use case untuk melakukan login.
///
/// Mengirim credentials ke server, menyimpan token jika berhasil,
/// dan mengelola remember me.
class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  /// Melakukan login dan menyimpan token.
  ///
  /// Returns [Right(AuthToken)] jika berhasil.
  /// Returns [Left(Failure)] jika gagal.
  Future<Either<Failure, AuthToken>> call(LoginParams params) async {
    final result = await _repository.login(params);

    return result.fold(
      (failure) => Left(failure),
      (token) async {
        // Simpan token
        await _repository.saveToken(token);

        // Handle remember me
        if (params.rememberMe) {
          await _repository.saveRememberedEmail(params.email);
        } else {
          await _repository.clearRememberedEmail();
        }

        return Right(token);
      },
    );
  }
}
