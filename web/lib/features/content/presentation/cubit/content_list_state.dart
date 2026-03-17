part of 'content_list_cubit.dart';

/// State untuk halaman daftar konten.
@freezed
sealed class ContentListState with _$ContentListState {
  /// State awal.
  const factory ContentListState.initial() = ContentListInitial;

  /// Sedang memuat data konten.
  const factory ContentListState.loading() = ContentListLoading;

  /// Data berhasil dimuat.
  const factory ContentListState.loaded({
    required List<Content> contents,
    @Default('') String searchQuery,
    @Default('') String statusFilter,
  }) = ContentListLoaded;

  /// Gagal memuat data.
  const factory ContentListState.error(String message) = ContentListError;
}
