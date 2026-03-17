import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';

/// Section Umum pada halaman pengaturan situs.
class SettingsGeneralSection extends StatelessWidget {
  /// Controller untuk nama situs.
  final TextEditingController siteNameController;

  /// Controller untuk deskripsi situs.
  final TextEditingController siteDescriptionController;

  /// Controller untuk URL situs.
  final TextEditingController siteUrlController;

  /// Controller untuk URL logo.
  final TextEditingController logoUrlController;

  /// Controller untuk URL favicon.
  final TextEditingController faviconUrlController;

  const SettingsGeneralSection({
    super.key,
    required this.siteNameController,
    required this.siteDescriptionController,
    required this.siteUrlController,
    required this.logoUrlController,
    required this.faviconUrlController,
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
              AppStrings.settingsSectionGeneral,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            TextFormField(
              controller: siteNameController,
              decoration: const InputDecoration(
                labelText: AppStrings.settingsSiteName,
                hintText: AppStrings.settingsSiteNameHint,
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.settingsSiteNameRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.spacingM),
            TextFormField(
              controller: siteDescriptionController,
              decoration: const InputDecoration(
                labelText: AppStrings.settingsSiteDescription,
                hintText: AppStrings.settingsSiteDescriptionHint,
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            TextFormField(
              controller: siteUrlController,
              decoration: const InputDecoration(
                labelText: AppStrings.settingsSiteUrl,
                hintText: AppStrings.settingsSiteUrlHint,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            TextFormField(
              controller: logoUrlController,
              decoration: const InputDecoration(
                labelText: AppStrings.settingsLogoUrl,
                hintText: AppStrings.settingsLogoUrlHint,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            TextFormField(
              controller: faviconUrlController,
              decoration: const InputDecoration(
                labelText: AppStrings.settingsFaviconUrl,
                hintText: AppStrings.settingsFaviconUrlHint,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
