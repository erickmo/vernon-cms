import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/login_params.dart';
import '../../domain/usecases/get_remembered_username_usecase.dart';
import '../../domain/usecases/login_usecase.dart';

part 'login_state.dart';
part 'login_cubit.freezed.dart';

/// Cubit untuk mengelola state halaman login.
class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase _loginUseCase;
  final GetRememberedUsernameUseCase _getRememberedUsernameUseCase;

  LoginCubit({
    required LoginUseCase loginUseCase,
    required GetRememberedUsernameUseCase getRememberedUsernameUseCase,
  })  : _loginUseCase = loginUseCase,
        _getRememberedUsernameUseCase = getRememberedUsernameUseCase,
        super(const LoginState.initial());

  /// Memuat email yang tersimpan dari remember me.
  Future<void> loadRememberedEmail() async {
    final result = await _getRememberedUsernameUseCase();

    result.fold(
      (_) => null,
      (email) {
        if (email != null && email.isNotEmpty) {
          emit(LoginState.initial(
            rememberedEmail: email,
            rememberMe: true,
          ));
        }
      },
    );
  }

  /// Set pesan sukses (misalnya setelah register berhasil).
  void setSuccessMessage(String message) {
    emit(LoginState.initial(successMessage: message));
  }

  /// Melakukan login dengan [email] dan [password].
  Future<void> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    emit(const LoginState.loading());

    final params = LoginParams(
      email: email,
      password: password,
      rememberMe: rememberMe,
    );

    final result = await _loginUseCase(params);

    result.fold(
      (failure) => emit(LoginState.error(failure.message)),
      (_) => emit(const LoginState.success()),
    );
  }
}
