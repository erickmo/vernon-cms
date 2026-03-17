part of 'domain_record_list_cubit.dart';

/// State untuk halaman daftar record domain.
@freezed
sealed class DomainRecordListState with _$DomainRecordListState {
  /// State awal.
  const factory DomainRecordListState.initial() = DomainRecordListInitial;

  /// Sedang memuat data record.
  const factory DomainRecordListState.loading() = DomainRecordListLoading;

  /// Data berhasil dimuat.
  const factory DomainRecordListState.loaded({
    required DomainDefinition domain,
    required List<DomainRecord> records,
    @Default('') String searchQuery,
  }) = DomainRecordListLoaded;

  /// Gagal memuat data.
  const factory DomainRecordListState.error(String message) =
      DomainRecordListError;
}
