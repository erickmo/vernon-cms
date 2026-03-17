part of 'register_cubit.dart';

/// State untuk halaman register.
@freezed
class RegisterState with _$RegisterState {
  /// State awal saat halaman register dibuka.
  const factory RegisterState.initial() = RegisterInitial;

  /// Sedang proses register ke server.
  const factory RegisterState.loading() = RegisterLoading;

  /// Register berhasil.
  const factory RegisterState.success() = RegisterSuccess;

  /// Register gagal dengan pesan error.
  const factory RegisterState.error(String message) = RegisterError;
}
