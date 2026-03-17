import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/page_entity.dart';

/// Tabel data halaman CMS.
class PageTable extends StatelessWidget {
  /// Daftar halaman yang ditampilkan.
  final List<PageEntity> pages;

  /// Callback saat user menekan tombol edit.
  final ValueChanged<PageEntity> onEdit;

  /// Callback saat user menekan tombol hapus.
  final ValueChanged<PageEntity> onDelete;

  const PageTable({
    super.key,
    required this.pages,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (pages.isEmpty) {
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
            DataColumn(label: Text(AppStrings.pageColumnName)),
            DataColumn(label: Text(AppStrings.pageColumnSlug)),
            DataColumn(label: Text(AppStrings.pageColumnActive)),
            DataColumn(label: Text(AppStrings.pageColumnCreatedAt)),
            DataColumn(label: Text(AppStrings.columnActions)),
          ],
          rows: pages.map((page) => _buildRow(page)).toList(),
        ),
      ),
    );
  }

  DataRow _buildRow(PageEntity page) {
    return DataRow(
      cells: [
        DataCell(_buildNameCell(page)),
        DataCell(Text(page.slug)),
        DataCell(_buildActiveChip(page.isActive)),
        DataCell(Text(_formatDate(page.createdAt))),
        DataCell(_buildActions(page)),
      ],
    );
  }

  Widget _buildNameCell(PageEntity page) {
    return Flexible(
      child: Text(
        page.name,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildActiveChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingS,
        vertical: AppDimensions.spacingXS,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.textHint.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Text(
        isActive ? AppStrings.pageActiveLabel : AppStrings.pageInactiveLabel,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isActive ? AppColors.success : AppColors.textHint,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  Widget _buildActions(PageEntity page) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: AppDimensions.iconS),
          color: AppColors.primary,
          tooltip: AppStrings.edit,
          onPressed: () => onEdit(page),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: AppDimensions.iconS),
          color: AppColors.error,
          tooltip: AppStrings.delete,
          onPressed: () => onDelete(page),
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
              Icons.web_outlined,
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
