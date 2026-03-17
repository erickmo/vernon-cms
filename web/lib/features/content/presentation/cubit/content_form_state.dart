part of 'content_form_cubit.dart';

/// State untuk form konten (create/edit).
@freezed
sealed class ContentFormState with _$ContentFormState {
  /// State awal (form kosong untuk create).
  const factory ContentFormState.initial() = ContentFormInitial;

  /// Sedang memuat data konten untuk edit.
  const factory ContentFormState.loading() = ContentFormLoading;

  /// Data konten berhasil dimuat untuk edit.
  const factory ContentFormState.loaded({
    required Content content,
  }) = ContentFormLoaded;

  /// Sedang menyimpan konten.
  const factory ContentFormState.saving() = ContentFormSaving;

  /// Konten berhasil disimpan.
  const factory ContentFormState.saved() = ContentFormSaved;

  /// Gagal memuat atau menyimpan data.
  const factory ContentFormState.error(String message) = ContentFormError;
}
