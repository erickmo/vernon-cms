import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/register_params.dart';
import '../../domain/usecases/register_usecase.dart';

part 'register_state.dart';
part 'register_cubit.freezed.dart';

/// Cubit untuk mengelola state halaman register.
class RegisterCubit extends Cubit<RegisterState> {
  final RegisterUseCase _registerUseCase;

  RegisterCubit({
    required RegisterUseCase registerUseCase,
  })  : _registerUseCase = registerUseCase,
        super(const RegisterState.initial());

  /// Melakukan registrasi user baru.
  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    emit(const RegisterState.loading());

    final params = RegisterParams(
      email: email,
      password: password,
      name: name,
    );

    final result = await _registerUseCase(params);

    result.fold(
      (failure) => emit(RegisterState.error(failure.message)),
      (_) => emit(const RegisterState.success()),
    );
  }
}
