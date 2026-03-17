import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/content_category.dart';

/// Dialog form untuk membuat atau mengedit kategori konten.
class ContentCategoryFormDialog extends StatefulWidget {
  /// Kategori yang akan diedit. Null jika membuat baru.
  final ContentCategory? category;

  /// Callback saat user menekan simpan.
  final ValueChanged<ContentCategory> onSave;

  const ContentCategoryFormDialog({
    super.key,
    this.category,
    required this.onSave,
  });

  /// Menampilkan dialog form.
  static Future<void> show({
    required BuildContext context,
    ContentCategory? category,
    required ValueChanged<ContentCategory> onSave,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ContentCategoryFormDialog(
        category: category,
        onSave: onSave,
      ),
    );
  }

  @override
  State<ContentCategoryFormDialog> createState() =>
      _ContentCategoryFormDialogState();
}

class _ContentCategoryFormDialogState extends State<ContentCategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _slugController;

  bool _autoSlug = true;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    final category = widget.category;
    _nameController = TextEditingController(text: category?.name ?? '');
    _slugController = TextEditingController(text: category?.slug ?? '');
    _autoSlug = category == null;

    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    if (_autoSlug) {
      _slugController.text = _generateSlug(_nameController.text);
    }
  }

  String _generateSlug(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final category = ContentCategory(
      id: widget.category?.id ?? '',
      name: _nameController.text.trim(),
      slug: _slugController.text.trim(),
      createdAt: widget.category?.createdAt ?? now,
      updatedAt: now,
    );

    widget.onSave(category);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _isEditing
            ? AppStrings.editCategory
            : AppStrings.addCategory,
      ),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildNameField(),
                const SizedBox(height: AppDimensions.spacingM),
                _buildSlugField(),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: _onSave,
          child: const Text(AppStrings.save),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: AppStrings.categoryName,
        hintText: AppStrings.categoryNameHint,
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return AppStrings.categoryNameRequired;
        }
        return null;
      },
    );
  }

  Widget _buildSlugField() {
    return TextFormField(
      controller: _slugController,
      decoration: const InputDecoration(
        labelText: AppStrings.categorySlug,
        hintText: AppStrings.categorySlugHint,
        border: OutlineInputBorder(),
      ),
      onChanged: (_) {
        _autoSlug = false;
      },
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return AppStrings.categorySlugRequired;
        }
        return null;
      },
    );
  }
}
