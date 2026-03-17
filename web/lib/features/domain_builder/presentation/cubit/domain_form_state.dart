part of 'domain_form_cubit.dart';

/// State untuk form domain builder (create/edit).
@freezed
sealed class DomainFormState with _$DomainFormState {
  /// State awal (form kosong untuk create).
  const factory DomainFormState.initial() = DomainFormInitial;

  /// Sedang memuat data domain untuk edit.
  const factory DomainFormState.loading() = DomainFormLoading;

  /// Data domain berhasil dimuat untuk edit.
  const factory DomainFormState.loaded({
    required DomainDefinition domain,
  }) = DomainFormLoaded;

  /// Sedang menyimpan domain.
  const factory DomainFormState.saving() = DomainFormSaving;

  /// Domain berhasil disimpan.
  const factory DomainFormState.saved({
    required DomainDefinition domain,
  }) = DomainFormSaved;

  /// Gagal memuat atau menyimpan data.
  const factory DomainFormState.error(String message) = DomainFormError;
}
