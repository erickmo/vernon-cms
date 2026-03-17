import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/content_category.dart';
import '../../../page_management/domain/entities/page_entity.dart';

/// Sidebar form konten (kanan): status, page, category, metadata.
class ContentFormSidebar extends StatelessWidget {
  /// Status konten saat ini (read-only display).
  final String status;

  /// ID halaman yang dipilih.
  final String? pageId;

  /// Callback saat halaman berubah.
  final ValueChanged<String?> onPageChanged;

  /// Daftar halaman yang tersedia.
  final List<PageEntity> pages;

  /// ID kategori yang dipilih.
  final String? categoryId;

  /// Callback saat kategori berubah.
  final ValueChanged<String?> onCategoryChanged;

  /// Daftar kategori yang tersedia.
  final List<ContentCategory> categories;

  /// Controller untuk metadata JSON.
  final TextEditingController metadataController;

  const ContentFormSidebar({
    super.key,
    required this.status,
    required this.pageId,
    required this.onPageChanged,
    required this.pages,
    required this.categoryId,
    required this.onCategoryChanged,
    required this.categories,
    required this.metadataController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStatusSection(),
        const SizedBox(height: AppDimensions.spacingM),
        _buildPageSection(),
        const SizedBox(height: AppDimensions.spacingM),
        _buildCategorySection(),
        const SizedBox(height: AppDimensions.spacingM),
        _buildMetadataSection(),
      ],
    );
  }

  Widget _buildStatusSection() {
    final Color chipColor;
    final String label;

    switch (status) {
      case 'published':
        chipColor = AppColors.success;
        label = AppStrings.contentStatusPublished;
      case 'archived':
        chipColor = AppColors.error;
        label = AppStrings.contentStatusArchived;
      default:
        chipColor = AppColors.textHint;
        label = AppStrings.contentStatusDraft;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.contentStatus,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingS,
                vertical: AppDimensions.spacingXS,
              ),
              decoration: BoxDecoration(
                color: chipColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: chipColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              AppStrings.contentPageSection,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            DropdownButtonFormField<String?>(
              initialValue: pageId,
              decoration: const InputDecoration(
                labelText: AppStrings.contentPage,
                border: OutlineInputBorder(),
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
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              AppStrings.contentCategorySection,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            DropdownButtonFormField<String?>(
              initialValue: categoryId,
              decoration: const InputDecoration(
                labelText: AppStrings.contentCategory,
                border: OutlineInputBorder(),
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
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.contentMetadataSection,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            const Text(
              AppStrings.contentMetadataHint,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            TextFormField(
              controller: metadataController,
              decoration: const InputDecoration(
                hintText: '{\n  "seo_title": "",\n  "tags": []\n}',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 8,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
