import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/login_params.dart';
import '../../domain/usecases/login_usecase.dart';

part 'login_state.dart';
part 'login_cubit.freezed.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase _loginUseCase;

  LoginCubit({required LoginUseCase loginUseCase})
      : _loginUseCase = loginUseCase,
        super(const LoginState.initial());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(const LoginState.loading());
    final result = await _loginUseCase(
      LoginParams(email: email, password: password),
    );
    result.fold(
      (failure) => emit(LoginState.error(failure.message)),
      (_) => emit(const LoginState.success()),
    );
  }
}
