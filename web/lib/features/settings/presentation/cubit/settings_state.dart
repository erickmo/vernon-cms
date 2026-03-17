part of 'settings_cubit.dart';

/// State untuk halaman pengaturan situs.
@freezed
sealed class SettingsState with _$SettingsState {
  /// State awal.
  const factory SettingsState.initial() = SettingsInitial;

  /// Sedang memuat data pengaturan.
  const factory SettingsState.loading() = SettingsLoading;

  /// Data berhasil dimuat.
  const factory SettingsState.loaded({
    required SiteSettings settings,
  }) = SettingsLoaded;

  /// Sedang menyimpan perubahan.
  const factory SettingsState.saving({
    required SiteSettings settings,
  }) = SettingsSaving;

  /// Perubahan berhasil disimpan.
  const factory SettingsState.saved({
    required SiteSettings settings,
  }) = SettingsSaved;

  /// Gagal memuat atau menyimpan data.
  const factory SettingsState.error(String message) = SettingsError;
}
