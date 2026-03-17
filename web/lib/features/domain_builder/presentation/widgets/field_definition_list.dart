import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/domain_definition.dart';
import '../../domain/entities/domain_field_definition.dart';
import '../../domain/entities/field_type.dart';
import 'field_definition_editor.dart';

/// Widget daftar field definition yang bisa di-reorder.
class FieldDefinitionList extends StatelessWidget {
  /// Daftar field saat ini.
  final List<DomainFieldDefinition> fields;

  /// Daftar domain tersedia untuk relasi.
  final List<DomainDefinition> availableDomains;

  /// Callback saat daftar field berubah.
  final ValueChanged<List<DomainFieldDefinition>> onChanged;

  const FieldDefinitionList({
    super.key,
    required this.fields,
    required this.availableDomains,
    required this.onChanged,
  });

  void _onReorder(int oldIndex, int newIndex) {
    final updatedFields = List<DomainFieldDefinition>.from(fields);
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = updatedFields.removeAt(oldIndex);
    updatedFields.insert(newIndex, item);

    // Update sortOrder
    final reordered = updatedFields.asMap().entries.map((entry) {
      return DomainFieldDefinition(
        id: entry.value.id,
        name: entry.value.name,
        label: entry.value.label,
        fieldType: entry.value.fieldType,
        isRequired: entry.value.isRequired,
        defaultValue: entry.value.defaultValue,
        placeholder: entry.value.placeholder,
        helpText: entry.value.helpText,
        sortOrder: entry.key,
        options: entry.value.options,
        relatedDomainId: entry.value.relatedDomainId,
        relatedDomainSlug: entry.value.relatedDomainSlug,
      );
    }).toList();

    onChanged(reordered);
  }

  void _addField() {
    final updatedFields = List<DomainFieldDefinition>.from(fields);
    final newField = DomainFieldDefinition(
      id: 'new_${DateTime.now().millisecondsSinceEpoch}',
      name: '',
      label: '',
      fieldType: FieldType.text,
      sortOrder: updatedFields.length,
    );
    updatedFields.add(newField);
    onChanged(updatedFields);
  }

  void _updateField(int index, DomainFieldDefinition field) {
    final updatedFields = List<DomainFieldDefinition>.from(fields);
    updatedFields[index] = field;
    onChanged(updatedFields);
  }

  void _deleteField(int index) {
    final updatedFields = List<DomainFieldDefinition>.from(fields);
    updatedFields.removeAt(index);
    onChanged(updatedFields);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              AppStrings.domainFieldsSection,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _addField,
              icon: const Icon(Icons.add, size: AppDimensions.iconS),
              label: const Text(AppStrings.domainAddField),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingM),
        if (fields.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.spacingXL),
              child: Text(
                AppStrings.domainNoFields,
                style: TextStyle(color: AppColors.textHint),
              ),
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: fields.length,
            onReorder: _onReorder,
            itemBuilder: (context, index) {
              final field = fields[index];
              return ReorderableDragStartListener(
                key: ValueKey(field.id),
                index: index,
                child: FieldDefinitionEditor(
                  field: field,
                  availableDomains: availableDomains,
                  onChanged: (updated) => _updateField(index, updated),
                  onDelete: () => _deleteField(index),
                ),
              );
            },
          ),
      ],
    );
  }
}
