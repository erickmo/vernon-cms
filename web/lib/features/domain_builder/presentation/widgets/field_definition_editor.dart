import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/domain_definition.dart';
import '../../domain/entities/domain_field_definition.dart';
import '../../domain/entities/field_type.dart';
import '../../domain/entities/select_option.dart';
import 'select_options_editor.dart';

/// Widget card editor untuk satu definisi field.
class FieldDefinitionEditor extends StatefulWidget {
  /// Field yang sedang diedit.
  final DomainFieldDefinition field;

  /// Daftar domain tersedia untuk relasi.
  final List<DomainDefinition> availableDomains;

  /// Callback saat field diperbarui.
  final ValueChanged<DomainFieldDefinition> onChanged;

  /// Callback saat field dihapus.
  final VoidCallback onDelete;

  const FieldDefinitionEditor({
    super.key,
    required this.field,
    required this.availableDomains,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<FieldDefinitionEditor> createState() => _FieldDefinitionEditorState();
}

class _FieldDefinitionEditorState extends State<FieldDefinitionEditor> {
  late final TextEditingController _labelController;
  late final TextEditingController _nameController;
  late final TextEditingController _placeholderController;
  late final TextEditingController _helpTextController;
  late final TextEditingController _defaultValueController;
  late FieldType _fieldType;
  late bool _isRequired;
  late List<SelectOption> _options;
  String? _relatedDomainId;
  String? _relatedDomainSlug;
  bool _autoName = true;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    final field = widget.field;
    _labelController = TextEditingController(text: field.label);
    _nameController = TextEditingController(text: field.name);
    _placeholderController = TextEditingController(
      text: field.placeholder ?? '',
    );
    _helpTextController = TextEditingController(text: field.helpText ?? '');
    _defaultValueController = TextEditingController(
      text: field.defaultValue ?? '',
    );
    _fieldType = field.fieldType;
    _isRequired = field.isRequired;
    _options = List.from(field.options);
    _relatedDomainId = field.relatedDomainId;
    _relatedDomainSlug = field.relatedDomainSlug;
    _autoName = field.name.isEmpty;

    _labelController.addListener(_onLabelChanged);
  }

  @override
  void dispose() {
    _labelController.dispose();
    _nameController.dispose();
    _placeholderController.dispose();
    _helpTextController.dispose();
    _defaultValueController.dispose();
    super.dispose();
  }

  void _onLabelChanged() {
    if (_autoName) {
      _nameController.text = _generateName(_labelController.text);
    }
    _emitChange();
  }

  String _generateName(String label) {
    return label
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  void _emitChange() {
    final updated = DomainFieldDefinition(
      id: widget.field.id,
      name: _nameController.text.trim(),
      label: _labelController.text.trim(),
      fieldType: _fieldType,
      isRequired: _isRequired,
      defaultValue: _defaultValueController.text.trim().isEmpty
          ? null
          : _defaultValueController.text.trim(),
      placeholder: _placeholderController.text.trim().isEmpty
          ? null
          : _placeholderController.text.trim(),
      helpText: _helpTextController.text.trim().isEmpty
          ? null
          : _helpTextController.text.trim(),
      sortOrder: widget.field.sortOrder,
      options: _options,
      relatedDomainId: _relatedDomainId,
      relatedDomainSlug: _relatedDomainSlug,
    );
    widget.onChanged(updated);
  }

  String _fieldTypeLabel(FieldType type) {
    switch (type) {
      case FieldType.text:
        return 'Text';
      case FieldType.textarea:
        return 'Textarea';
      case FieldType.number:
        return 'Number';
      case FieldType.email:
        return 'Email';
      case FieldType.url:
        return 'URL';
      case FieldType.phone:
        return 'Phone';
      case FieldType.date:
        return 'Date';
      case FieldType.select:
        return 'Select';
      case FieldType.checkbox:
        return 'Checkbox';
      case FieldType.imageUrl:
        return 'Image URL';
      case FieldType.richText:
        return 'Rich Text';
      case FieldType.relation:
        return 'Relation';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingS),
      child: Column(
        children: [
          _buildHeader(),
          if (_isExpanded) _buildEditor(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return ListTile(
      leading: const Icon(Icons.drag_handle, color: AppColors.textHint),
      title: Text(
        _labelController.text.isNotEmpty
            ? _labelController.text
            : AppStrings.domainFieldNewField,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingS,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: Text(
              _fieldTypeLabel(_fieldType),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (_isRequired) ...[
            const SizedBox(width: AppDimensions.spacingXS),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingS,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: const Text(
                AppStrings.domainFieldRequired,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
            ),
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: widget.onDelete,
          ),
        ],
      ),
    );
  }

  Widget _buildEditor() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingM,
        0,
        AppDimensions.spacingM,
        AppDimensions.spacingM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Divider(),
          const SizedBox(height: AppDimensions.spacingS),
          // Label dan Name
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _labelController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.domainFieldLabel,
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.domainFieldName,
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (_) {
                    _autoName = false;
                    _emitChange();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          // Type dropdown dan Required toggle
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<FieldType>(
                  initialValue: _fieldType,
                  decoration: const InputDecoration(
                    labelText: AppStrings.domainFieldType,
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: FieldType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(_fieldTypeLabel(type)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _fieldType = value;
                      });
                      _emitChange();
                    }
                  },
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: SwitchListTile(
                  title: const Text(AppStrings.domainFieldRequired),
                  value: _isRequired,
                  onChanged: (value) {
                    setState(() {
                      _isRequired = value;
                    });
                    _emitChange();
                  },
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          // Placeholder dan Default Value
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _placeholderController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.domainFieldPlaceholder,
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (_) => _emitChange(),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: TextField(
                  controller: _defaultValueController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.domainFieldDefaultValue,
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (_) => _emitChange(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          // Help Text
          TextField(
            controller: _helpTextController,
            decoration: const InputDecoration(
              labelText: AppStrings.domainFieldHelpText,
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (_) => _emitChange(),
          ),
          // Select options
          if (_fieldType == FieldType.select) ...[
            const SizedBox(height: AppDimensions.spacingM),
            SelectOptionsEditor(
              options: _options,
              onChanged: (options) {
                _options = options;
                _emitChange();
              },
            ),
          ],
          // Relation domain picker
          if (_fieldType == FieldType.relation) ...[
            const SizedBox(height: AppDimensions.spacingM),
            DropdownButtonFormField<String>(
              initialValue: _relatedDomainSlug,
              decoration: const InputDecoration(
                labelText: AppStrings.domainFieldRelatedDomain,
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: widget.availableDomains
                  .map(
                    (d) => DropdownMenuItem(
                      value: d.slug,
                      child: Text(d.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _relatedDomainSlug = value;
                  _relatedDomainId = widget.availableDomains
                      .where((d) => d.slug == value)
                      .map((d) => d.id)
                      .firstOrNull;
                });
                _emitChange();
              },
            ),
          ],
        ],
      ),
    );
  }
}
