import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';

/// Dialog yang menampilkan token yang baru dibuat (hanya sekali).
class ApiTokenCreatedDialog extends StatelessWidget {
  /// Token string yang baru dibuat.
  final String token;

  const ApiTokenCreatedDialog({
    super.key,
    required this.token,
  });

  /// Menampilkan dialog.
  static Future<void> show({
    required BuildContext context,
    required String token,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ApiTokenCreatedDialog(token: token),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: AppDimensions.iconL,
          ),
          SizedBox(width: AppDimensions.spacingS),
          Text(AppStrings.apiTokenCreated),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingM),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.warning,
                    size: AppDimensions.iconM,
                  ),
                  SizedBox(width: AppDimensions.spacingS),
                  Expanded(
                    child: Text(
                      AppStrings.apiTokenWarning,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.spacingM),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                border: Border.all(color: AppColors.divider),
              ),
              child: SelectableText(
                token,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: token));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(AppStrings.apiTokenCopied),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text(AppStrings.apiTokenCopyButton),
              ),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.confirm),
        ),
      ],
    );
  }
}
