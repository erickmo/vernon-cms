part of 'domain_builder_cubit.dart';

/// State untuk halaman daftar domain builder.
@freezed
sealed class DomainBuilderState with _$DomainBuilderState {
  /// State awal.
  const factory DomainBuilderState.initial() = DomainBuilderInitial;

  /// Sedang memuat data domain.
  const factory DomainBuilderState.loading() = DomainBuilderLoading;

  /// Data berhasil dimuat.
  const factory DomainBuilderState.loaded({
    required List<DomainDefinition> domains,
  }) = DomainBuilderLoaded;

  /// Gagal memuat data.
  const factory DomainBuilderState.error(String message) = DomainBuilderError;
}
