import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/content_category.dart';
import '../cubit/content_category_cubit.dart';
import '../widgets/content_category_form_dialog.dart';
import '../widgets/content_category_table.dart';
import '../widgets/delete_confirmation_dialog.dart';

/// Halaman daftar kategori konten.
class ContentCategoryPage extends StatelessWidget {
  const ContentCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ContentCategoryCubit>()..loadCategories(),
      child: const _ContentCategoryView(),
    );
  }
}

class _ContentCategoryView extends StatelessWidget {
  const _ContentCategoryView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContentCategoryCubit, ContentCategoryState>(
      listener: _onStateChanged,
      builder: (context, state) => state.when(
        initial: () => const SizedBox.shrink(),
        loading: () => const Center(child: CircularProgressIndicator()),
        loaded: (categories) =>
            _buildContent(context, categories),
        error: (message) => _buildError(context, message),
      ),
    );
  }

  void _onStateChanged(BuildContext context, ContentCategoryState state) {
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
    List<ContentCategory> categories,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: AppDimensions.spacingL),
          ContentCategoryTable(
            categories: categories,
            onEdit: (category) => _showFormDialog(
              context,
              category: category,
            ),
            onDelete: (category) => _showDeleteDialog(context, category),
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
          AppStrings.contentCategoryTitle,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showFormDialog(context),
          icon: const Icon(Icons.add),
          label: const Text(AppStrings.addCategory),
        ),
      ],
    );
  }

  void _showFormDialog(
    BuildContext context, {
    ContentCategory? category,
  }) {
    final cubit = context.read<ContentCategoryCubit>();
    ContentCategoryFormDialog.show(
      context: context,
      category: category,
      onSave: (updatedCategory) {
        if (category != null) {
          cubit.updateCategory(updatedCategory);
        } else {
          cubit.createCategory(updatedCategory);
        }
      },
    );
  }

  void _showDeleteDialog(BuildContext context, ContentCategory category) {
    final cubit = context.read<ContentCategoryCubit>();
    DeleteConfirmationDialog.show(
      context: context,
      title: AppStrings.deleteCategory,
      message: '${AppStrings.deleteCategoryConfirm} "${category.name}"?',
      onConfirm: () => cubit.deleteCategory(category.id),
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
                  context.read<ContentCategoryCubit>().loadCategories(),
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      );
}
