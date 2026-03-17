import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/select_option.dart';

/// Widget editor untuk mengelola daftar opsi pada field tipe select.
class SelectOptionsEditor extends StatefulWidget {
  /// Daftar opsi saat ini.
  final List<SelectOption> options;

  /// Callback saat daftar opsi berubah.
  final ValueChanged<List<SelectOption>> onChanged;

  const SelectOptionsEditor({
    super.key,
    required this.options,
    required this.onChanged,
  });

  @override
  State<SelectOptionsEditor> createState() => _SelectOptionsEditorState();
}

class _SelectOptionsEditorState extends State<SelectOptionsEditor> {
  late List<SelectOption> _options;

  @override
  void initState() {
    super.initState();
    _options = List.from(widget.options);
  }

  @override
  void didUpdateWidget(covariant SelectOptionsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.options != widget.options) {
      _options = List.from(widget.options);
    }
  }

  void _addOption() {
    final labelController = TextEditingController();
    final valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.domainFieldAddOption),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelController,
                decoration: const InputDecoration(
                  labelText: AppStrings.domainFieldOptionLabel,
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  if (valueController.text.isEmpty) {
                    valueController.text = value
                        .toLowerCase()
                        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
                        .replaceAll(RegExp(r'\s+'), '_');
                  }
                },
              ),
              const SizedBox(height: AppDimensions.spacingM),
              TextField(
                controller: valueController,
                decoration: const InputDecoration(
                  labelText: AppStrings.domainFieldOptionValue,
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final label = labelController.text.trim();
              final value = valueController.text.trim();
              if (label.isNotEmpty && value.isNotEmpty) {
                setState(() {
                  _options.add(SelectOption(label: label, value: value));
                });
                widget.onChanged(_options);
                Navigator.of(dialogContext).pop();
              }
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }

  void _removeOption(int index) {
    setState(() {
      _options.removeAt(index);
    });
    widget.onChanged(_options);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              AppStrings.domainFieldOptions,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton.icon(
              onPressed: _addOption,
              icon: const Icon(Icons.add, size: AppDimensions.iconS),
              label: const Text(AppStrings.domainFieldAddOption),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingXS),
        if (_options.isEmpty)
          const Padding(
            padding: EdgeInsets.all(AppDimensions.spacingS),
            child: Text(
              AppStrings.domainFieldNoOptions,
              style: TextStyle(color: AppColors.textHint),
            ),
          )
        else
          ..._options.asMap().entries.map(
                (entry) => Card(
                  margin: const EdgeInsets.only(
                    bottom: AppDimensions.spacingXS,
                  ),
                  child: ListTile(
                    dense: true,
                    title: Text(entry.value.label),
                    subtitle: Text(
                      entry.value.value,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: AppDimensions.iconS,
                        color: AppColors.error,
                      ),
                      onPressed: () => _removeOption(entry.key),
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}
