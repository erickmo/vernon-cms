import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';

/// Section Maintenance pada halaman pengaturan situs.
class SettingsMaintenanceSection extends StatelessWidget {
  /// Apakah mode maintenance aktif.
  final bool maintenanceMode;

  /// Callback saat toggle maintenance mode.
  final ValueChanged<bool> onMaintenanceModeChanged;

  /// Controller untuk pesan maintenance.
  final TextEditingController maintenanceMessageController;

  const SettingsMaintenanceSection({
    super.key,
    required this.maintenanceMode,
    required this.onMaintenanceModeChanged,
    required this.maintenanceMessageController,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.settingsSectionMaintenance,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            SwitchListTile(
              title: const Text(AppStrings.settingsMaintenanceMode),
              subtitle: const Text(AppStrings.settingsMaintenanceModeHint),
              value: maintenanceMode,
              onChanged: onMaintenanceModeChanged,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            TextFormField(
              controller: maintenanceMessageController,
              decoration: const InputDecoration(
                labelText: AppStrings.settingsMaintenanceMessage,
                hintText: AppStrings.settingsMaintenanceMessageHint,
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
