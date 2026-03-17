import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../content/presentation/widgets/delete_confirmation_dialog.dart';
import '../../domain/entities/domain_definition.dart';
import '../cubit/domain_builder_cubit.dart';
import '../widgets/domain_builder_table.dart';

/// Halaman daftar domain builder.
class DomainBuilderListPage extends StatelessWidget {
  const DomainBuilderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DomainBuilderCubit>()..loadDomains(),
      child: const _DomainBuilderListView(),
    );
  }
}

class _DomainBuilderListView extends StatelessWidget {
  const _DomainBuilderListView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DomainBuilderCubit, DomainBuilderState>(
      listener: _onStateChanged,
      builder: (context, state) => state.when(
        initial: () => const SizedBox.shrink(),
        loading: () => const Center(child: CircularProgressIndicator()),
        loaded: (domains) => _buildContent(context, domains),
        error: (message) => _buildError(context, message),
      ),
    );
  }

  void _onStateChanged(BuildContext context, DomainBuilderState state) {
    state.whenOrNull(
      error: (message) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<DomainDefinition> domains,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: AppDimensions.spacingL),
          DomainBuilderTable(
            domains: domains,
            onEdit: (domain) => context.go(
              '/domain-builder/${domain.id}/edit',
            ),
            onDelete: (domain) => _showDeleteDialog(context, domain),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          AppStrings.domainBuilderTitle,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => context.go('/domain-builder/create'),
          icon: const Icon(Icons.add),
          label: const Text(AppStrings.domainAdd),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, DomainDefinition domain) {
    final cubit = context.read<DomainBuilderCubit>();
    DeleteConfirmationDialog.show(
      context: context,
      title: AppStrings.domainDelete,
      message: '${AppStrings.domainDeleteConfirm} "${domain.name}"?',
      onConfirm: () => cubit.deleteDomain(domain.id),
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
                  context.read<DomainBuilderCubit>().loadDomains(),
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      );
}
