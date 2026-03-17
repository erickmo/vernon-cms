part of 'content_category_cubit.dart';

/// State untuk halaman kategori konten.
@freezed
sealed class ContentCategoryState with _$ContentCategoryState {
  /// State awal.
  const factory ContentCategoryState.initial() = ContentCategoryInitial;

  /// Sedang memuat data kategori.
  const factory ContentCategoryState.loading() = ContentCategoryLoading;

  /// Data berhasil dimuat.
  const factory ContentCategoryState.loaded({
    required List<ContentCategory> categories,
  }) = ContentCategoryLoaded;

  /// Gagal memuat data.
  const factory ContentCategoryState.error(String message) =
      ContentCategoryError;
}
