import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/api_token.dart';

/// Dialog form untuk membuat atau mengedit API token.
class ApiTokenFormDialog extends StatefulWidget {
  /// Token yang diedit (null jika membuat baru).
  final ApiToken? token;

  /// Callback saat simpan.
  final ValueChanged<ApiToken> onSave;

  const ApiTokenFormDialog({
    super.key,
    this.token,
    required this.onSave,
  });

  /// Menampilkan dialog.
  static Future<void> show({
    required BuildContext context,
    ApiToken? token,
    required ValueChanged<ApiToken> onSave,
  }) {
    return showDialog(
      context: context,
      builder: (_) => ApiTokenFormDialog(
        token: token,
        onSave: onSave,
      ),
    );
  }

  @override
  State<ApiTokenFormDialog> createState() => _ApiTokenFormDialogState();
}

class _ApiTokenFormDialogState extends State<ApiTokenFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _selectedPermissions = <String>{};
  DateTime? _expiresAt;

  static const _availablePermissions = [
    'content.read',
    'content.write',
    'media.read',
    'media.write',
    'page.read',
    'page.write',
    'user.read',
    'user.write',
    'settings.read',
    'settings.write',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.token != null) {
      _nameController.text = widget.token!.name;
      _selectedPermissions.addAll(widget.token!.permissions);
      _expiresAt = widget.token!.expiresAt;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.token != null;
    return AlertDialog(
      title: Text(
        isEditing ? AppStrings.apiTokenEdit : AppStrings.apiTokenCreate,
      ),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.apiTokenName,
                    hintText: AppStrings.apiTokenNameHint,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.apiTokenNameRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.spacingM),
                Text(
                  AppStrings.apiTokenPermissions,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppDimensions.spacingS),
                Wrap(
                  spacing: AppDimensions.spacingS,
                  runSpacing: AppDimensions.spacingS,
                  children: _availablePermissions.map((permission) {
                    final isSelected =
                        _selectedPermissions.contains(permission);
                    return FilterChip(
                      label: Text(permission),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedPermissions.add(permission);
                          } else {
                            _selectedPermissions.remove(permission);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                if (!isEditing) ...[
                  const SizedBox(height: AppDimensions.spacingM),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(AppStrings.apiTokenExpiry),
                    subtitle: Text(
                      _expiresAt != null
                          ? '${_expiresAt!.day}/${_expiresAt!.month}/${_expiresAt!.year}'
                          : AppStrings.apiTokenNoExpiry,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: _pickExpiryDate,
                        ),
                        if (_expiresAt != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () =>
                                setState(() => _expiresAt = null),
                          ),
                      ],
                    ),
                  ),
                ],
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

  Future<void> _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiresAt ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _expiresAt = picked);
    }
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final token = ApiToken(
        id: widget.token?.id ?? '',
        name: _nameController.text.trim(),
        prefix: widget.token?.prefix ?? '',
        permissions: _selectedPermissions.toList(),
        expiresAt: _expiresAt,
        isActive: widget.token?.isActive ?? true,
        createdAt: widget.token?.createdAt ?? DateTime.now(),
      );
      widget.onSave(token);
      Navigator.of(context).pop();
    }
  }
}
