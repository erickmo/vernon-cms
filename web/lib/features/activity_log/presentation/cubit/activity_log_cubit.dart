import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/activity_log.dart';
import '../../domain/usecases/get_activity_logs_usecase.dart';

part 'activity_log_state.dart';
part 'activity_log_cubit.freezed.dart';

/// Cubit untuk mengelola state halaman log aktivitas.
class ActivityLogCubit extends Cubit<ActivityLogState> {
  final GetActivityLogsUseCase _getActivityLogsUseCase;

  ActivityLogCubit({
    required GetActivityLogsUseCase getActivityLogsUseCase,
  })  : _getActivityLogsUseCase = getActivityLogsUseCase,
        super(const ActivityLogState.initial());

  /// Memuat daftar log aktivitas.
  Future<void> loadActivityLogs({
    String? search,
    String? action,
    String? entityType,
    String? userId,
    String? dateFrom,
    String? dateTo,
  }) async {
    emit(const ActivityLogState.loading());

    final result = await _getActivityLogsUseCase(
      search: search,
      action: action,
      entityType: entityType,
      userId: userId,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );

    result.fold(
      (failure) => emit(ActivityLogState.error(failure.message)),
      (logs) => emit(ActivityLogState.loaded(
        logs: logs,
        searchQuery: search ?? '',
        actionFilter: action,
        entityTypeFilter: entityType,
      )),
    );
  }
}
