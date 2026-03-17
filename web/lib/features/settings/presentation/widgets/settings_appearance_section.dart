import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';

/// Section Tampilan pada halaman pengaturan situs.
class SettingsAppearanceSection extends StatelessWidget {
  /// Controller untuk warna primer.
  final TextEditingController primaryColorController;

  /// Controller untuk warna sekunder.
  final TextEditingController secondaryColorController;

  /// Controller untuk teks footer.
  final TextEditingController footerTextController;

  const SettingsAppearanceSection({
    super.key,
    required this.primaryColorController,
    required this.secondaryColorController,
    required this.footerTextController,
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
              AppStrings.settingsSectionAppearance,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            TextFormField(
              controller: primaryColorController,
              decoration: const InputDecoration(
                labelText: AppStrings.settingsPrimaryColor,
                hintText: AppStrings.settingsPrimaryColorHint,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            TextFormField(
              controller: secondaryColorController,
              decoration: const InputDecoration(
                labelText: AppStrings.settingsSecondaryColor,
                hintText: AppStrings.settingsSecondaryColorHint,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            TextFormField(
              controller: footerTextController,
              decoration: const InputDecoration(
                labelText: AppStrings.settingsFooterText,
                hintText: AppStrings.settingsFooterTextHint,
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
