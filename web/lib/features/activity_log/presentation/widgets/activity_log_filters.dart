import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';

/// Bar filter untuk log aktivitas.
class ActivityLogFilters extends StatelessWidget {
  /// Controller untuk search.
  final TextEditingController searchController;

  /// Filter aksi yang dipilih.
  final String? selectedAction;

  /// Filter tipe entitas yang dipilih.
  final String? selectedEntityType;

  /// Callback saat filter berubah.
  final void Function({
    String? search,
    String? action,
    String? entityType,
  }) onFilterChanged;

  const ActivityLogFilters({
    super.key,
    required this.searchController,
    required this.selectedAction,
    required this.selectedEntityType,
    required this.onFilterChanged,
  });

  static const _actions = [
    'created',
    'updated',
    'deleted',
    'login',
    'logout',
    'published',
    'archived',
  ];

  static const _entityTypes = [
    'content',
    'page',
    'category',
    'domain',
    'user',
    'settings',
    'media',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.spacingM,
      runSpacing: AppDimensions.spacingM,
      children: [
        SizedBox(
          width: 280,
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: AppStrings.activityLogSearch,
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        onFilterChanged(
                          action: selectedAction,
                          entityType: selectedEntityType,
                        );
                      },
                    )
                  : null,
            ),
            onSubmitted: (value) {
              onFilterChanged(
                search: value.isNotEmpty ? value : null,
                action: selectedAction,
                entityType: selectedEntityType,
              );
            },
          ),
        ),
        SizedBox(
          width: 180,
          child: DropdownButtonFormField<String?>(
            initialValue: selectedAction,
            decoration: const InputDecoration(
              labelText: AppStrings.activityLogAction,
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text(AppStrings.activityLogAllActions),
              ),
              ..._actions.map(
                (action) => DropdownMenuItem(
                  value: action,
                  child: Text(action),
                ),
              ),
            ],
            onChanged: (value) {
              onFilterChanged(
                search: searchController.text.isNotEmpty
                    ? searchController.text
                    : null,
                action: value,
                entityType: selectedEntityType,
              );
            },
          ),
        ),
        SizedBox(
          width: 180,
          child: DropdownButtonFormField<String?>(
            initialValue: selectedEntityType,
            decoration: const InputDecoration(
              labelText: AppStrings.activityLogEntityType,
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text(AppStrings.activityLogAllEntityTypes),
              ),
              ..._entityTypes.map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                ),
              ),
            ],
            onChanged: (value) {
              onFilterChanged(
                search: searchController.text.isNotEmpty
                    ? searchController.text
                    : null,
                action: selectedAction,
                entityType: value,
              );
            },
          ),
        ),
      ],
    );
  }
}
