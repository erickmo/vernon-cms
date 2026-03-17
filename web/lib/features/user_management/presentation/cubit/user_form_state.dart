part of 'user_form_cubit.dart';

/// State untuk form user (create/edit).
@freezed
sealed class UserFormState with _$UserFormState {
  /// State awal (form kosong untuk create).
  const factory UserFormState.initial() = UserFormInitial;

  /// Sedang memuat data user untuk edit.
  const factory UserFormState.loading() = UserFormLoading;

  /// Data user berhasil dimuat untuk edit.
  const factory UserFormState.loaded({
    required CmsUser user,
  }) = UserFormLoaded;

  /// Sedang menyimpan user.
  const factory UserFormState.saving() = UserFormSaving;

  /// User berhasil disimpan.
  const factory UserFormState.saved() = UserFormSaved;

  /// Gagal memuat atau menyimpan data.
  const factory UserFormState.error(String message) = UserFormError;
}
