import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/cms_user.dart';

/// Tabel data user.
///
/// Kolom: Email, Name, Role (chip), Active (chip), Created At, Actions.
class UserTable extends StatelessWidget {
  /// Daftar user yang ditampilkan.
  final List<CmsUser> users;

  /// Callback saat user menekan tombol edit.
  final ValueChanged<CmsUser> onEdit;

  /// Callback saat user menekan tombol hapus.
  final ValueChanged<CmsUser> onDelete;

  const UserTable({
    super.key,
    required this.users,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
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
            DataColumn(label: Text(AppStrings.userColumnEmail)),
            DataColumn(label: Text(AppStrings.userColumnName)),
            DataColumn(label: Text(AppStrings.userColumnRole)),
            DataColumn(label: Text(AppStrings.userColumnStatus)),
            DataColumn(label: Text(AppStrings.userColumnCreatedAt)),
            DataColumn(label: Text(AppStrings.columnActions)),
          ],
          rows: users.map((user) => _buildRow(user)).toList(),
        ),
      ),
    );
  }

  DataRow _buildRow(CmsUser user) {
    return DataRow(
      cells: [
        DataCell(Text(user.email)),
        DataCell(Text(user.name)),
        DataCell(_buildRoleChip(user.role)),
        DataCell(_buildStatusChip(user.isActive)),
        DataCell(Text(_formatDate(user.createdAt))),
        DataCell(_buildActions(user)),
      ],
    );
  }

  Widget _buildRoleChip(String role) {
    final Color chipColor;
    final String label;

    switch (role) {
      case 'admin':
        chipColor = AppColors.error;
        label = 'Admin';
      case 'editor':
        chipColor = AppColors.success;
        label = 'Editor';
      case 'viewer':
        chipColor = AppColors.info;
        label = 'Viewer';
      default:
        chipColor = AppColors.textHint;
        label = role;
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

  Widget _buildStatusChip(bool isActive) {
    final chipColor = isActive ? AppColors.success : AppColors.textHint;
    final label =
        isActive ? AppStrings.userStatusActive : AppStrings.userStatusInactive;

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

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  Widget _buildActions(CmsUser user) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: AppDimensions.iconS),
          color: AppColors.primary,
          tooltip: AppStrings.edit,
          onPressed: () => onEdit(user),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: AppDimensions.iconS),
          color: AppColors.error,
          tooltip: AppStrings.delete,
          onPressed: () => onDelete(user),
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
              Icons.people_outlined,
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
