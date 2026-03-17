import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/site_settings.dart';
import '../../domain/usecases/get_settings_usecase.dart';
import '../../domain/usecases/update_settings_usecase.dart';

part 'settings_state.dart';
part 'settings_cubit.freezed.dart';

/// Cubit untuk mengelola state halaman pengaturan situs.
class SettingsCubit extends Cubit<SettingsState> {
  final GetSettingsUseCase _getSettingsUseCase;
  final UpdateSettingsUseCase _updateSettingsUseCase;

  SettingsCubit({
    required GetSettingsUseCase getSettingsUseCase,
    required UpdateSettingsUseCase updateSettingsUseCase,
  })  : _getSettingsUseCase = getSettingsUseCase,
        _updateSettingsUseCase = updateSettingsUseCase,
        super(const SettingsState.initial());

  /// Memuat pengaturan situs.
  Future<void> loadSettings() async {
    emit(const SettingsState.loading());

    final result = await _getSettingsUseCase();

    result.fold(
      (failure) => emit(SettingsState.error(failure.message)),
      (settings) => emit(SettingsState.loaded(settings: settings)),
    );
  }

  /// Menyimpan perubahan pengaturan situs.
  Future<void> saveSettings(SiteSettings settings) async {
    emit(SettingsState.saving(settings: settings));

    final result = await _updateSettingsUseCase(settings);

    result.fold(
      (failure) => emit(SettingsState.error(failure.message)),
      (updatedSettings) =>
          emit(SettingsState.saved(settings: updatedSettings)),
    );
  }
}
