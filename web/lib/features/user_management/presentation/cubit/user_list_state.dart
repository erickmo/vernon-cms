part of 'user_list_cubit.dart';

/// State untuk halaman daftar user.
@freezed
sealed class UserListState with _$UserListState {
  /// State awal.
  const factory UserListState.initial() = UserListInitial;

  /// Sedang memuat data user.
  const factory UserListState.loading() = UserListLoading;

  /// Data berhasil dimuat.
  const factory UserListState.loaded({
    required List<CmsUser> users,
    @Default('') String searchQuery,
    @Default('') String roleFilter,
  }) = UserListLoaded;

  /// Gagal memuat data.
  const factory UserListState.error(String message) = UserListError;
}
