import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/daily_content.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/usecases/get_daily_content_usecase.dart';
import '../../domain/usecases/get_dashboard_stats_usecase.dart';

part 'dashboard_state.dart';
part 'dashboard_cubit.freezed.dart';

/// Cubit untuk mengelola state halaman dashboard.
class DashboardCubit extends Cubit<DashboardState> {
  final GetDashboardStatsUseCase _getStatsUseCase;
  final GetDailyContentUseCase _getDailyContentUseCase;

  DashboardCubit({
    required GetDashboardStatsUseCase getStatsUseCase,
    required GetDailyContentUseCase getDailyContentUseCase,
  })  : _getStatsUseCase = getStatsUseCase,
        _getDailyContentUseCase = getDailyContentUseCase,
        super(const DashboardState.initial());

  /// Memuat semua data dashboard secara bersamaan.
  Future<void> loadDashboard() async {
    emit(const DashboardState.loading());

    final results = await Future.wait([
      _getStatsUseCase(),
      _getDailyContentUseCase(),
    ]);

    final statsResult = results[0];
    final dailyResult = results[1];

    // Cek apakah ada error
    final statsError = statsResult.fold((f) => f.message, (_) => null);
    final dailyError = dailyResult.fold((f) => f.message, (_) => null);

    if (statsError != null) {
      emit(DashboardState.error(statsError));
      return;
    }
    if (dailyError != null) {
      emit(DashboardState.error(dailyError));
      return;
    }

    final stats = statsResult.fold((_) => null, (s) => s) as DashboardStats;
    final daily =
        dailyResult.fold((_) => null, (d) => d) as List<DailyContent>;

    emit(DashboardState.loaded(stats: stats, dailyContent: daily));
  }
}
