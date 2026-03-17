part of 'page_list_cubit.dart';

/// State untuk halaman daftar halaman CMS.
@freezed
sealed class PageListState with _$PageListState {
  /// State awal.
  const factory PageListState.initial() = PageListInitial;

  /// Sedang memuat data halaman.
  const factory PageListState.loading() = PageListLoading;

  /// Data berhasil dimuat.
  const factory PageListState.loaded({
    required List<PageEntity> pages,
    @Default('') String searchQuery,
  }) = PageListLoaded;

  /// Gagal memuat data.
  const factory PageListState.error(String message) = PageListError;
}
