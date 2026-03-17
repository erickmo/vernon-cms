import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/cms_user.dart';
import '../../domain/usecases/delete_user_usecase.dart';
import '../../domain/usecases/get_users_usecase.dart';

part 'user_list_state.dart';
part 'user_list_cubit.freezed.dart';

/// Cubit untuk mengelola state halaman daftar user.
class UserListCubit extends Cubit<UserListState> {
  final GetUsersUseCase _getUsersUseCase;
  final DeleteUserUseCase _deleteUserUseCase;

  UserListCubit({
    required GetUsersUseCase getUsersUseCase,
    required DeleteUserUseCase deleteUserUseCase,
  })  : _getUsersUseCase = getUsersUseCase,
        _deleteUserUseCase = deleteUserUseCase,
        super(const UserListState.initial());

  /// Memuat daftar user.
  Future<void> loadUsers({
    String? search,
    String? role,
  }) async {
    emit(const UserListState.loading());

    final result = await _getUsersUseCase(
      search: search,
      role: role,
    );

    result.fold(
      (failure) => emit(UserListState.error(failure.message)),
      (users) => emit(UserListState.loaded(
        users: users,
        searchQuery: search ?? '',
        roleFilter: role ?? '',
      )),
    );
  }

  /// Menghapus user berdasarkan [id].
  Future<bool> deleteUser(String id) async {
    final result = await _deleteUserUseCase(id);

    return result.fold(
      (failure) {
        emit(UserListState.error(failure.message));
        return false;
      },
      (_) {
        _reloadWithCurrentFilters();
        return true;
      },
    );
  }

  void _reloadWithCurrentFilters() {
    final currentState = state;
    final search = currentState is UserListLoaded
        ? currentState.searchQuery
        : null;
    final role = currentState is UserListLoaded
        ? currentState.roleFilter
        : null;

    loadUsers(
      search: search?.isNotEmpty == true ? search : null,
      role: role?.isNotEmpty == true ? role : null,
    );
  }
}
