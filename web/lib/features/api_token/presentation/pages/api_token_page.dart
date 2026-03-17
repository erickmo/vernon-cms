import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/api_token.dart';
import '../../../content/presentation/widgets/delete_confirmation_dialog.dart';
import '../cubit/api_token_cubit.dart';
import '../widgets/api_token_created_dialog.dart';
import '../widgets/api_token_form_dialog.dart';
import '../widgets/api_token_table.dart';

/// Halaman daftar API token.
class ApiTokenPage extends StatelessWidget {
  const ApiTokenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ApiTokenCubit>()..loadTokens(),
      child: const _ApiTokenView(),
    );
  }
}

class _ApiTokenView extends StatelessWidget {
  const _ApiTokenView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ApiTokenCubit, ApiTokenState>(
      listener: _onStateChanged,
      builder: (context, state) => state.when(
        initial: () => const SizedBox.shrink(),
        loading: () => const Center(child: CircularProgressIndicator()),
        loaded: (tokens) => _buildContent(context, tokens),
        error: (message) => _buildError(context, message),
      ),
    );
  }

  void _onStateChanged(BuildContext context, ApiTokenState state) {
    state.whenOrNull(
      error: (message) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<ApiToken> tokens) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: AppDimensions.spacingL),
          ApiTokenTable(
            tokens: tokens,
            onEdit: (token) => _showFormDialog(context, token: token),
            onDelete: (token) => _showDeleteDialog(context, token),
            onToggleActive: (token) =>
                context.read<ApiTokenCubit>().toggleTokenActive(token.id),
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
          AppStrings.apiTokenTitle,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showFormDialog(context),
          icon: const Icon(Icons.add),
          label: const Text(AppStrings.apiTokenCreate),
        ),
      ],
    );
  }

  void _showFormDialog(BuildContext context, {ApiToken? token}) {
    final cubit = context.read<ApiTokenCubit>();
    ApiTokenFormDialog.show(
      context: context,
      token: token,
      onSave: (updatedToken) async {
        if (token != null) {
          cubit.updateToken(updatedToken);
        } else {
          final createdToken = await cubit.createToken(updatedToken);
          if (createdToken != null &&
              createdToken.token.isNotEmpty &&
              context.mounted) {
            ApiTokenCreatedDialog.show(
              context: context,
              token: createdToken.token,
            );
          }
        }
      },
    );
  }

  void _showDeleteDialog(BuildContext context, ApiToken token) {
    final cubit = context.read<ApiTokenCubit>();
    DeleteConfirmationDialog.show(
      context: context,
      title: AppStrings.apiTokenRevoke,
      message: '${AppStrings.apiTokenRevokeConfirm} "${token.name}"?',
      onConfirm: () => cubit.deleteToken(token.id),
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
                  context.read<ApiTokenCubit>().loadTokens(),
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      );
}
