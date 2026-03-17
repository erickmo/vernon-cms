part of 'dashboard_cubit.dart';

/// State untuk halaman dashboard.
@freezed
class DashboardState with _$DashboardState {
  /// State awal.
  const factory DashboardState.initial() = _Initial;

  /// Sedang memuat data dashboard.
  const factory DashboardState.loading() = _Loading;

  /// Data berhasil dimuat.
  const factory DashboardState.loaded({
    required DashboardStats stats,
    required List<DailyContent> dailyContent,
  }) = _Loaded;

  /// Gagal memuat data.
  const factory DashboardState.error(String message) = _Error;
}
