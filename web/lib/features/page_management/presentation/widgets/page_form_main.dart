import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import 'page_variables_table.dart';

/// Panel utama form halaman (kiri): Name, Slug, Variables table.
class PageFormMain extends StatelessWidget {
  /// Controller untuk nama halaman.
  final TextEditingController nameController;

  /// Controller untuk slug.
  final TextEditingController slugController;

  /// Map variables halaman saat ini.
  final Map<String, dynamic> variables;

  /// Callback saat variables berubah.
  final ValueChanged<Map<String, dynamic>> onVariablesChanged;

  /// Callback saat slug diubah manual (mematikan auto-slug).
  final VoidCallback onSlugManualEdit;

  const PageFormMain({
    super.key,
    required this.nameController,
    required this.slugController,
    required this.variables,
    required this.onVariablesChanged,
    required this.onSlugManualEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildBasicSection(),
        const SizedBox(height: AppDimensions.spacingL),
        _buildVariablesSection(),
      ],
    );
  }

  Widget _buildBasicSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.pageTabContent,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: AppStrings.pageNameLabel,
                hintText: AppStrings.pageNameHint,
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.pageNameRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.spacingM),
            TextFormField(
              controller: slugController,
              decoration: const InputDecoration(
                labelText: AppStrings.pageSlugLabel,
                hintText: AppStrings.pageSlugHint,
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => onSlugManualEdit(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.pageSlugRequired;
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVariablesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.pageVariablesLabel,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            const Text(
              AppStrings.pageVariablesHint,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            PageVariablesTable(
              variables: variables,
              onChanged: onVariablesChanged,
            ),
          ],
        ),
      ),
    );
  }
}
