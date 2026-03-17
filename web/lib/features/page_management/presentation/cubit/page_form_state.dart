part of 'page_form_cubit.dart';

/// State untuk form halaman CMS.
@freezed
sealed class PageFormState with _$PageFormState {
  /// State awal (mode create).
  const factory PageFormState.initial() = PageFormInitial;

  /// Sedang memuat detail halaman (mode edit).
  const factory PageFormState.loading() = PageFormLoading;

  /// Detail halaman berhasil dimuat (mode edit).
  const factory PageFormState.loaded({
    required PageEntity page,
  }) = PageFormLoaded;

  /// Sedang menyimpan halaman.
  const factory PageFormState.saving() = PageFormSaving;

  /// Halaman berhasil disimpan.
  const factory PageFormState.saved() = PageFormSaved;

  /// Gagal memuat atau menyimpan.
  const factory PageFormState.error(String message) = PageFormError;
}
