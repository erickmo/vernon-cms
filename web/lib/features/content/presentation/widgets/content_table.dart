import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/content.dart';

/// Tabel data konten.
class ContentTable extends StatelessWidget {
  /// Daftar konten yang ditampilkan.
  final List<Content> contents;

  /// Callback saat user menekan tombol edit.
  final ValueChanged<Content> onEdit;

  /// Callback saat user menekan tombol hapus.
  final ValueChanged<Content> onDelete;

  /// Callback saat user menekan tombol publish.
  final ValueChanged<Content>? onPublish;

  const ContentTable({
    super.key,
    required this.contents,
    required this.onEdit,
    required this.onDelete,
    this.onPublish,
  });

  @override
  Widget build(BuildContext context) {
    if (contents.isEmpty) {
      return _buildEmpty();
    }

    return Card(
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            AppColors.primary.withValues(alpha: 0.05),
          ),
          columns: const [
            DataColumn(label: Text(AppStrings.contentColumnTitle)),
            DataColumn(label: Text(AppStrings.contentColumnStatus)),
            DataColumn(label: Text(AppStrings.contentColumnPublishedAt)),
            DataColumn(label: Text(AppStrings.columnActions)),
          ],
          rows: contents.map((content) => _buildRow(content)).toList(),
        ),
      ),
    );
  }

  DataRow _buildRow(Content content) {
    return DataRow(
      cells: [
        DataCell(_buildTitleCell(content)),
        DataCell(_buildStatusChip(content.status)),
        DataCell(Text(_formatDate(content.publishedAt))),
        DataCell(_buildActions(content)),
      ],
    );
  }

  Widget _buildTitleCell(Content content) {
    return Text(
      content.title,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontWeight: FontWeight.w500),
    );
  }

  Widget _buildStatusChip(String status) {
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

    return Container(
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
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: chipColor,
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  Widget _buildActions(Content content) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (content.status == 'draft' && onPublish != null)
          IconButton(
            icon: const Icon(Icons.publish_outlined, size: AppDimensions.iconS),
            color: AppColors.success,
            tooltip: AppStrings.contentPublish,
            onPressed: () => onPublish!(content),
          ),
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: AppDimensions.iconS),
          color: AppColors.primary,
          tooltip: AppStrings.edit,
          onPressed: () => onEdit(content),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: AppDimensions.iconS),
          color: AppColors.error,
          tooltip: AppStrings.delete,
          onPressed: () => onDelete(content),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.spacingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.article_outlined,
              size: AppDimensions.avatarL,
              color: AppColors.textHint,
            ),
            SizedBox(height: AppDimensions.spacingM),
            Text(
              AppStrings.emptyData,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
