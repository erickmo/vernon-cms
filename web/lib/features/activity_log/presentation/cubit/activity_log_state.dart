part of 'activity_log_cubit.dart';

/// State untuk halaman log aktivitas.
@freezed
sealed class ActivityLogState with _$ActivityLogState {
  /// State awal.
  const factory ActivityLogState.initial() = ActivityLogInitial;

  /// Sedang memuat data log.
  const factory ActivityLogState.loading() = ActivityLogLoading;

  /// Data berhasil dimuat.
  const factory ActivityLogState.loaded({
    required List<ActivityLog> logs,
    @Default('') String searchQuery,
    String? actionFilter,
    String? entityTypeFilter,
  }) = ActivityLogLoaded;

  /// Gagal memuat data.
  const factory ActivityLogState.error(String message) = ActivityLogError;
}
