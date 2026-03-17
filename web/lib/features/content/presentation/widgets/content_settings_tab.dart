import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/content_category.dart';
import '../../../page_management/domain/entities/page_entity.dart';

/// Tab pengaturan form konten: status, kategori, halaman.
class ContentSettingsTab extends StatelessWidget {
  final String status;
  final ValueChanged<String?> onStatusChanged;
  final String? pageId;
  final ValueChanged<String?> onPageChanged;
  final List<PageEntity> pages;
  final String? categoryId;
  final ValueChanged<String?> onCategoryChanged;
  final List<ContentCategory> categories;

  const ContentSettingsTab({
    super.key,
    required this.status,
    required this.onStatusChanged,
    required this.pageId,
    required this.onPageChanged,
    required this.pages,
    required this.categoryId,
    required this.onCategoryChanged,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSection(
              title: 'Status Konten',
              icon: Icons.flag_outlined,
              child: DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(
                  labelText: AppStrings.contentStatus,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'draft',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 16, color: AppColors.textHint),
                        SizedBox(width: 8),
                        Text(AppStrings.contentStatusDraft),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'published',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline, size: 16, color: AppColors.success),
                        SizedBox(width: 8),
                        Text(AppStrings.contentStatusPublished),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'archived',
                    child: Row(
                      children: [
                        Icon(Icons.archive_outlined, size: 16, color: AppColors.error),
                        SizedBox(width: 8),
                        Text(AppStrings.contentStatusArchived),
                      ],
                    ),
                  ),
                ],
                onChanged: onStatusChanged,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            _buildSection(
              title: 'Kategori',
              icon: Icons.label_outline,
              child: DropdownButtonFormField<String?>(
                value: categoryId,
                decoration: const InputDecoration(
                  labelText: AppStrings.contentCategory,
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text(AppStrings.contentNoCategory),
                  ),
                  ...categories.map(
                    (c) => DropdownMenuItem<String?>(
                      value: c.id,
                      child: Text(c.name),
                    ),
                  ),
                ],
                onChanged: onCategoryChanged,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            _buildSection(
              title: 'Halaman Terkait',
              icon: Icons.web_outlined,
              child: DropdownButtonFormField<String?>(
                value: pageId,
                decoration: const InputDecoration(
                  labelText: AppStrings.contentPage,
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text(AppStrings.contentNoPage),
                  ),
                  ...pages.map(
                    (p) => DropdownMenuItem<String?>(
                      value: p.id,
                      child: Text(p.name),
                    ),
                  ),
                ],
                onChanged: onPageChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) =>
      Container(
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(color: AppColors.divider, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: 15, color: AppColors.primary),
                const SizedBox(width: AppDimensions.spacingS),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingM),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: AppDimensions.spacingM),
            child,
          ],
        ),
      );
}
