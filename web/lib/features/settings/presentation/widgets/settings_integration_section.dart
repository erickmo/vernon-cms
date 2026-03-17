import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';

/// Section Integrasi pada halaman pengaturan situs.
class SettingsIntegrationSection extends StatelessWidget {
  /// Controller untuk Google Analytics ID.
  final TextEditingController googleAnalyticsIdController;

  /// Controller untuk custom head code.
  final TextEditingController customHeadCodeController;

  /// Controller untuk custom body code.
  final TextEditingController customBodyCodeController;

  const SettingsIntegrationSection({
    super.key,
    required this.googleAnalyticsIdController,
    required this.customHeadCodeController,
    required this.customBodyCodeController,
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
              AppStrings.settingsSectionIntegration,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            TextFormField(
              controller: googleAnalyticsIdController,
              decoration: const InputDecoration(
                labelText: AppStrings.settingsGoogleAnalyticsId,
                hintText: AppStrings.settingsGoogleAnalyticsIdHint,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            TextFormField(
              controller: customHeadCodeController,
              decoration: const InputDecoration(
                labelText: AppStrings.settingsCustomHeadCode,
                hintText: AppStrings.settingsCustomHeadCodeHint,
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            TextFormField(
              controller: customBodyCodeController,
              decoration: const InputDecoration(
                labelText: AppStrings.settingsCustomBodyCode,
                hintText: AppStrings.settingsCustomBodyCodeHint,
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
  }
}
