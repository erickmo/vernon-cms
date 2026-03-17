import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/icon_resolver.dart';
import '../../domain/entities/domain_definition.dart';

/// Tabel daftar domain definitions.
class DomainBuilderTable extends StatelessWidget {
  /// Daftar domain.
  final List<DomainDefinition> domains;

  /// Callback saat tombol edit ditekan.
  final ValueChanged<DomainDefinition> onEdit;

  /// Callback saat tombol hapus ditekan.
  final ValueChanged<DomainDefinition> onDelete;

  const DomainBuilderTable({
    super.key,
    required this.domains,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (domains.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.spacingXL),
          child: Text(
            AppStrings.emptyData,
            style: TextStyle(color: AppColors.textHint),
          ),
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(
          AppColors.background,
        ),
        columns: const [
          DataColumn(label: Text(AppStrings.domainColumnIcon)),
          DataColumn(label: Text(AppStrings.domainColumnName)),
          DataColumn(label: Text(AppStrings.columnSlug)),
          DataColumn(label: Text(AppStrings.domainColumnFieldCount)),
          DataColumn(label: Text(AppStrings.domainColumnSidebar)),
          DataColumn(label: Text(AppStrings.columnActions)),
        ],
        rows: domains.map((domain) => _buildRow(domain)).toList(),
      ),
    );
  }

  DataRow _buildRow(DomainDefinition domain) {
    return DataRow(
      cells: [
        DataCell(
          Icon(
            IconResolver.resolve(domain.icon),
            color: AppColors.textSecondary,
          ),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                domain.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (domain.description != null &&
                  domain.description!.isNotEmpty)
                Text(
                  domain.description!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        DataCell(Text(domain.slug)),
        DataCell(Text('${domain.fields.length}')),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingS,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: Text(
              domain.sidebarSection,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.info,
              ),
            ),
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => onEdit(domain),
                tooltip: AppStrings.edit,
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                ),
                onPressed: () => onDelete(domain),
                tooltip: AppStrings.delete,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
