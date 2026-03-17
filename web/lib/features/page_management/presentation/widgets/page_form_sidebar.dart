import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';

/// Sidebar form halaman (kanan): is_active toggle.
class PageFormSidebar extends StatelessWidget {
  /// Apakah halaman aktif.
  final bool isActive;

  /// Callback saat is_active berubah.
  final ValueChanged<bool> onIsActiveChanged;

  const PageFormSidebar({
    super.key,
    required this.isActive,
    required this.onIsActiveChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.pageSettingsSection,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            SwitchListTile(
              title: const Text(AppStrings.pageIsActiveLabel),
              value: isActive,
              onChanged: (value) => onIsActiveChanged(value),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}
