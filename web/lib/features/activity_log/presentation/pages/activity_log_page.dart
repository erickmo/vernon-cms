import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/activity_log.dart';
import '../cubit/activity_log_cubit.dart';
import '../widgets/activity_log_filters.dart';
import '../widgets/activity_log_timeline.dart';

/// Halaman daftar log aktivitas.
class ActivityLogPage extends StatelessWidget {
  const ActivityLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ActivityLogCubit>()..loadActivityLogs(),
      child: const _ActivityLogView(),
    );
  }
}

class _ActivityLogView extends StatefulWidget {
  const _ActivityLogView();

  @override
  State<_ActivityLogView> createState() => _ActivityLogViewState();
}

class _ActivityLogViewState extends State<_ActivityLogView> {
  final _searchController = TextEditingController();
  String? _actionFilter;
  String? _entityTypeFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ActivityLogCubit, ActivityLogState>(
      listener: _onStateChanged,
      builder: (context, state) => state.when(
        initial: () => const SizedBox.shrink(),
        loading: () => const Center(child: CircularProgressIndicator()),
        loaded: (logs, searchQuery, actionFilter, entityTypeFilter) =>
            _buildContent(context, logs),
        error: (message) => _buildError(context, message),
      ),
    );
  }

  void _onStateChanged(BuildContext context, ActivityLogState state) {
    state.whenOrNull(
      error: (message) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<ActivityLog> logs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppDimensions.spacingL),
          ActivityLogFilters(
            searchController: _searchController,
            selectedAction: _actionFilter,
            selectedEntityType: _entityTypeFilter,
            onFilterChanged: _onFilterChanged,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          ActivityLogTimeline(logs: logs),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      AppStrings.activityLogTitle,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  void _onFilterChanged({
    String? search,
    String? action,
    String? entityType,
  }) {
    setState(() {
      _actionFilter = action;
      _entityTypeFilter = entityType;
    });
    context.read<ActivityLogCubit>().loadActivityLogs(
          search: search,
          action: action,
          entityType: entityType,
        );
  }

  Widget _buildError(BuildContext context, String message) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: AppDimensions.avatarL,
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              message,
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            ElevatedButton(
              onPressed: () =>
                  context.read<ActivityLogCubit>().loadActivityLogs(),
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      );
}
