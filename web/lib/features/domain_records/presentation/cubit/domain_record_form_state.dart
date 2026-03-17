part of 'domain_record_form_cubit.dart';

/// State untuk form record domain.
@freezed
sealed class DomainRecordFormState with _$DomainRecordFormState {
  /// State awal (form kosong untuk create).
  const factory DomainRecordFormState.initial() = DomainRecordFormInitial;

  /// Sedang memuat data record untuk edit.
  const factory DomainRecordFormState.loading() = DomainRecordFormLoading;

  /// Data record berhasil dimuat untuk edit.
  const factory DomainRecordFormState.loaded({
    required DomainRecord record,
  }) = DomainRecordFormLoaded;

  /// Sedang menyimpan record.
  const factory DomainRecordFormState.saving() = DomainRecordFormSaving;

  /// Record berhasil disimpan.
  const factory DomainRecordFormState.saved({
    required DomainRecord record,
  }) = DomainRecordFormSaved;

  /// Gagal memuat atau menyimpan data.
  const factory DomainRecordFormState.error(String message) =
      DomainRecordFormError;
}
