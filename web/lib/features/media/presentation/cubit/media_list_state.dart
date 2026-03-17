part of 'media_list_cubit.dart';

/// State untuk halaman daftar media.
@freezed
sealed class MediaListState with _$MediaListState {
  /// State awal.
  const factory MediaListState.initial() = MediaListInitial;

  /// Sedang memuat data media.
  const factory MediaListState.loading() = MediaListLoading;

  /// Data berhasil dimuat.
  const factory MediaListState.loaded({
    required List<MediaFile> files,
    @Default([]) List<String> folders,
    @Default('') String searchQuery,
    String? mimeTypeFilter,
    String? folderFilter,
  }) = MediaListLoaded;

  /// Gagal memuat data.
  const factory MediaListState.error(String message) = MediaListError;
}
