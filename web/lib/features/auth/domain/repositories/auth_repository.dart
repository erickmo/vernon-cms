import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/auth_token.dart';
import '../entities/login_params.dart';
import '../entities/register_params.dart';

/// Interface repository untuk autentikasi.
abstract class AuthRepository {
  /// Login dengan email dan password.
  Future<Either<Failure, AuthToken>> login(LoginParams params);

  /// Register user baru dengan email, password, dan name.
  Future<Either<Failure, void>> register(RegisterParams params);

  /// Simpan token ke local storage.
  Future<Either<Failure, void>> saveToken(AuthToken token);

  /// Ambil token yang tersimpan.
  Future<Either<Failure, AuthToken>> getSavedToken();

  /// Hapus token (logout).
  Future<Either<Failure, void>> clearToken();

  /// Simpan email untuk remember me.
  Future<Either<Failure, void>> saveRememberedEmail(String email);

  /// Ambil email yang disimpan dari remember me.
  Future<Either<Failure, String?>> getRememberedEmail();

  /// Hapus email yang disimpan.
  Future<Either<Failure, void>> clearRememberedEmail();
}
