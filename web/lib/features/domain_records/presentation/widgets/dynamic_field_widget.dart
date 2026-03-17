import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../domain_builder/domain/entities/domain_field_definition.dart';
import '../../../domain_builder/domain/entities/field_type.dart';
import '../../domain/entities/record_option.dart';

/// Widget dinamis yang merender form field berdasarkan [FieldType].
class DynamicFieldWidget extends StatelessWidget {
  /// Definisi field.
  final DomainFieldDefinition field;

  /// Nilai saat ini.
  final dynamic value;

  /// Callback saat nilai berubah.
  final ValueChanged<dynamic> onChanged;

  /// Daftar opsi relation (untuk field tipe relation).
  final List<RecordOption> relationOptions;

  const DynamicFieldWidget({
    super.key,
    required this.field,
    required this.value,
    required this.onChanged,
    this.relationOptions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: _buildField(context),
    );
  }

  Widget _buildField(BuildContext context) {
    switch (field.fieldType) {
      case FieldType.text:
        return _buildTextFormField(keyboardType: TextInputType.text);
      case FieldType.email:
        return _buildTextFormField(keyboardType: TextInputType.emailAddress);
      case FieldType.url:
        return _buildTextFormField(keyboardType: TextInputType.url);
      case FieldType.phone:
        return _buildTextFormField(keyboardType: TextInputType.phone);
      case FieldType.textarea:
      case FieldType.richText:
        return _buildTextFormField(
          keyboardType: TextInputType.multiline,
          maxLines: 5,
        );
      case FieldType.number:
        return _buildTextFormField(keyboardType: TextInputType.number);
      case FieldType.date:
        return _buildDateField(context);
      case FieldType.select:
        return _buildSelectField();
      case FieldType.checkbox:
        return _buildCheckboxField();
      case FieldType.imageUrl:
        return _buildTextFormField(
          keyboardType: TextInputType.url,
          hintOverride: field.placeholder ?? 'https://example.com/image.jpg',
        );
      case FieldType.relation:
        return _buildRelationField();
    }
  }

  Widget _buildTextFormField({
    required TextInputType keyboardType,
    int maxLines = 1,
    String? hintOverride,
  }) {
    return TextFormField(
      initialValue: value?.toString() ?? field.defaultValue ?? '',
      decoration: InputDecoration(
        labelText: field.label,
        hintText: hintOverride ?? field.placeholder,
        helperText: field.helpText,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: field.isRequired
          ? (v) => (v == null || v.isEmpty) ? '${field.label} wajib diisi' : null
          : null,
      onChanged: onChanged,
    );
  }

  Widget _buildDateField(BuildContext context) {
    final textValue = value?.toString() ?? field.defaultValue ?? '';
    final controller = TextEditingController(text: textValue);

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: field.label,
        hintText: field.placeholder ?? 'YYYY-MM-DD',
        helperText: field.helpText,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      readOnly: true,
      validator: field.isRequired
          ? (v) => (v == null || v.isEmpty) ? '${field.label} wajib diisi' : null
          : null,
      onTap: () async {
        final now = DateTime.now();
        final initialDate = _parseDate(textValue) ?? now;
        final picked = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          final formatted =
              '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
          controller.text = formatted;
          onChanged(formatted);
        }
      },
    );
  }

  DateTime? _parseDate(String text) {
    try {
      return DateTime.parse(text);
    } catch (_) {
      return null;
    }
  }

  Widget _buildSelectField() {
    final currentValue = value?.toString();
    final options = field.options;

    return DropdownButtonFormField<String>(
      initialValue: options.any((o) => o.value == currentValue) ? currentValue : null,
      decoration: InputDecoration(
        labelText: field.label,
        helperText: field.helpText,
        border: const OutlineInputBorder(),
      ),
      items: options
          .map((option) => DropdownMenuItem(
                value: option.value,
                child: Text(option.label),
              ))
          .toList(),
      validator: field.isRequired
          ? (v) => (v == null || v.isEmpty) ? '${field.label} wajib diisi' : null
          : null,
      onChanged: (v) => onChanged(v),
    );
  }

  Widget _buildCheckboxField() {
    final boolValue = _parseBool(value) ?? _parseBool(field.defaultValue) ?? false;

    return SwitchListTile(
      title: Text(field.label),
      subtitle: field.helpText != null ? Text(field.helpText!) : null,
      value: boolValue,
      contentPadding: EdgeInsets.zero,
      onChanged: (v) => onChanged(v),
    );
  }

  bool? _parseBool(dynamic val) {
    if (val is bool) return val;
    if (val is String) {
      if (val.toLowerCase() == 'true') return true;
      if (val.toLowerCase() == 'false') return false;
    }
    return null;
  }

  Widget _buildRelationField() {
    final currentValue = value?.toString();

    return DropdownButtonFormField<String>(
      initialValue: relationOptions.any((o) => o.id == currentValue)
          ? currentValue
          : null,
      decoration: InputDecoration(
        labelText: field.label,
        helperText: field.helpText,
        border: const OutlineInputBorder(),
      ),
      items: relationOptions
          .map((option) => DropdownMenuItem(
                value: option.id,
                child: Text(option.label),
              ))
          .toList(),
      validator: field.isRequired
          ? (v) => (v == null || v.isEmpty) ? '${field.label} wajib diisi' : null
          : null,
      onChanged: (v) => onChanged(v),
    );
  }
}
