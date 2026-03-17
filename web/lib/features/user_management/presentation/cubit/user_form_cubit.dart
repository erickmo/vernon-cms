import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/cms_user.dart';
import '../../domain/usecases/create_user_usecase.dart';
import '../../domain/usecases/get_user_detail_usecase.dart';
import '../../domain/usecases/update_user_usecase.dart';

part 'user_form_state.dart';
part 'user_form_cubit.freezed.dart';

/// Cubit untuk mengelola state form user (create/edit).
class UserFormCubit extends Cubit<UserFormState> {
  final GetUserDetailUseCase _getUserDetailUseCase;
  final CreateUserUseCase _createUserUseCase;
  final UpdateUserUseCase _updateUserUseCase;

  UserFormCubit({
    required GetUserDetailUseCase getUserDetailUseCase,
    required CreateUserUseCase createUserUseCase,
    required UpdateUserUseCase updateUserUseCase,
  })  : _getUserDetailUseCase = getUserDetailUseCase,
        _createUserUseCase = createUserUseCase,
        _updateUserUseCase = updateUserUseCase,
        super(const UserFormState.initial());

  /// Memuat detail user untuk editing.
  Future<void> loadUser(String id) async {
    emit(const UserFormState.loading());

    final result = await _getUserDetailUseCase(id);

    result.fold(
      (failure) => emit(UserFormState.error(failure.message)),
      (user) => emit(UserFormState.loaded(user: user)),
    );
  }

  /// Membuat user baru.
  Future<bool> createUser(CmsUser user,
      {required String passwordHash}) async {
    emit(const UserFormState.saving());

    final result =
        await _createUserUseCase(user, passwordHash: passwordHash);

    return result.fold(
      (failure) {
        emit(UserFormState.error(failure.message));
        return false;
      },
      (_) {
        emit(const UserFormState.saved());
        return true;
      },
    );
  }

  /// Memperbarui user yang sudah ada.
  Future<bool> updateUser(CmsUser user) async {
    emit(const UserFormState.saving());

    final result = await _updateUserUseCase(user);

    return result.fold(
      (failure) {
        emit(UserFormState.error(failure.message));
        return false;
      },
      (_) {
        emit(const UserFormState.saved());
        return true;
      },
    );
  }
}
