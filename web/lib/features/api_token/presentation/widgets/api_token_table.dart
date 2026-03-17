import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/api_token.dart';

/// Tabel daftar API token.
class ApiTokenTable extends StatelessWidget {
  /// Daftar API token.
  final List<ApiToken> tokens;

  /// Callback saat edit token.
  final ValueChanged<ApiToken> onEdit;

  /// Callback saat hapus token.
  final ValueChanged<ApiToken> onDelete;

  /// Callback saat toggle aktif token.
  final ValueChanged<ApiToken> onToggleActive;

  const ApiTokenTable({
    super.key,
    required this.tokens,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    if (tokens.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.spacingXL),
          child: Text(AppStrings.emptyData),
        ),
      );
    }

    return Card(
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          columns: const [
            DataColumn(label: Text(AppStrings.apiTokenColumnName)),
            DataColumn(label: Text(AppStrings.apiTokenColumnPrefix)),
            DataColumn(label: Text(AppStrings.apiTokenColumnPermissions)),
            DataColumn(label: Text(AppStrings.apiTokenColumnStatus)),
            DataColumn(label: Text(AppStrings.apiTokenColumnLastUsed)),
            DataColumn(label: Text(AppStrings.apiTokenColumnExpires)),
            DataColumn(label: Text(AppStrings.columnActions)),
          ],
          rows: tokens.map((token) => _buildRow(context, token)).toList(),
        ),
      ),
    );
  }

  DataRow _buildRow(BuildContext context, ApiToken token) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    return DataRow(
      cells: [
        DataCell(Text(
          token.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        )),
        DataCell(Text(
          token.prefix,
          style: const TextStyle(
            fontFamily: 'monospace',
            color: AppColors.textSecondary,
          ),
        )),
        DataCell(_buildPermissionChips(token.permissions)),
        DataCell(_buildStatusBadge(token.isActive)),
        DataCell(Text(
          token.lastUsedAt != null
              ? dateFormat.format(token.lastUsedAt!)
              : '-',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        )),
        DataCell(Text(
          token.expiresAt != null
              ? dateFormat.format(token.expiresAt!)
              : AppStrings.apiTokenNoExpiry,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        )),
        DataCell(_buildActions(context, token)),
      ],
    );
  }

  Widget _buildPermissionChips(List<String> permissions) {
    if (permissions.isEmpty) {
      return const Text('-');
    }
    return Wrap(
      spacing: AppDimensions.spacingXS,
      children: permissions
          .take(3)
          .map(
            (p) => Chip(
              label: Text(
                p,
                style: const TextStyle(fontSize: 10),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingXS,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingS,
        vertical: AppDimensions.spacingXS,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Text(
        isActive ? AppStrings.apiTokenActive : AppStrings.apiTokenInactive,
        style: TextStyle(
          color: isActive ? AppColors.success : AppColors.error,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, ApiToken token) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: AppDimensions.iconS),
          tooltip: AppStrings.edit,
          onPressed: () => onEdit(token),
        ),
        IconButton(
          icon: Icon(
            token.isActive
                ? Icons.pause_circle_outline
                : Icons.play_circle_outline,
            size: AppDimensions.iconS,
          ),
          tooltip: token.isActive
              ? AppStrings.apiTokenDeactivate
              : AppStrings.apiTokenActivate,
          onPressed: () => onToggleActive(token),
        ),
        IconButton(
          icon: const Icon(
            Icons.delete_outline,
            size: AppDimensions.iconS,
            color: AppColors.error,
          ),
          tooltip: AppStrings.delete,
          onPressed: () => onDelete(token),
        ),
      ],
    );
  }
}
