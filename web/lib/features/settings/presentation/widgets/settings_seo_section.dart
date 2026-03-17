import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';

/// Section SEO Default pada halaman pengaturan situs.
class SettingsSeoSection extends StatelessWidget {
  /// Controller untuk meta title default.
  final TextEditingController defaultMetaTitleController;

  /// Controller untuk meta description default.
  final TextEditingController defaultMetaDescriptionController;

  /// Controller untuk OG image default.
  final TextEditingController defaultOgImageController;

  const SettingsSeoSection({
    super.key,
    required this.defaultMetaTitleController,
    required this.defaultMetaDescriptionController,
    required this.defaultOgImageController,
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
              AppStrings.settingsSectionSeo,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            TextFormField(
              controller: defaultMetaTitleController,
              decoration: const InputDecoration(
                labelText: AppStrings.settingsDefaultMetaTitle,
                hintText: AppStrings.settingsDefaultMetaTitleHint,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            TextFormField(
              controller: defaultMetaDescriptionController,
              decoration: const InputDecoration(
                labelText: AppStrings.settingsDefaultMetaDescription,
                hintText: AppStrings.settingsDefaultMetaDescriptionHint,
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            TextFormField(
              controller: defaultOgImageController,
              decoration: const InputDecoration(
                labelText: AppStrings.settingsDefaultOgImage,
                hintText: AppStrings.settingsDefaultOgImageHint,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
