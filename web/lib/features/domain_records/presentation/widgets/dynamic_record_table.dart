import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../domain_builder/domain/entities/domain_definition.dart';
import '../../../domain_builder/domain/entities/domain_field_definition.dart';
import '../../domain/entities/domain_record.dart';

/// Tabel dinamis yang auto-generate kolom dari field definitions.
class DynamicRecordTable extends StatelessWidget {
  /// Definisi domain.
  final DomainDefinition domain;

  /// Daftar record.
  final List<DomainRecord> records;

  /// Callback saat tombol edit ditekan.
  final ValueChanged<DomainRecord> onEdit;

  /// Callback saat tombol hapus ditekan.
  final ValueChanged<DomainRecord> onDelete;

  const DynamicRecordTable({
    super.key,
    required this.domain,
    required this.records,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final visibleFields = _getVisibleFields();

    if (records.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.spacingXL),
          child: Text(
            AppStrings.emptyData,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Card(
      elevation: 1,
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          headingRowColor:
              WidgetStateProperty.all(AppColors.background),
          columns: [
            ...visibleFields.map(
              (field) => DataColumn(label: Text(field.label)),
            ),
            const DataColumn(label: Text(AppStrings.columnActions)),
          ],
          rows: records.map((record) => _buildRow(record, visibleFields)).toList(),
        ),
      ),
    );
  }

  /// Ambil field yang tampil di tabel (max 5 kolom pertama berdasarkan sortOrder).
  List<DomainFieldDefinition> _getVisibleFields() {
    final sorted = List<DomainFieldDefinition>.from(domain.fields)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return sorted.take(5).toList();
  }

  DataRow _buildRow(
    DomainRecord record,
    List<DomainFieldDefinition> visibleFields,
  ) {
    return DataRow(
      cells: [
        ...visibleFields.map((field) {
          final cellValue = record.data[field.name];
          return DataCell(Text(
            cellValue?.toString() ?? '-',
            overflow: TextOverflow.ellipsis,
          ));
        }),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: AppDimensions.iconS),
                tooltip: AppStrings.edit,
                onPressed: () => onEdit(record),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  size: AppDimensions.iconS,
                  color: AppColors.error,
                ),
                tooltip: AppStrings.delete,
                onPressed: () => onDelete(record),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
