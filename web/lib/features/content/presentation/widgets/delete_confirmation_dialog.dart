import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';

/// Dialog konfirmasi penghapusan yang dapat digunakan ulang.
class DeleteConfirmationDialog extends StatelessWidget {
  /// Judul dialog.
  final String title;

  /// Pesan konfirmasi.
  final String message;

  /// Callback saat user menekan tombol hapus.
  final VoidCallback onConfirm;

  const DeleteConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
  });

  /// Menampilkan dialog dan mengembalikan [true] jika user konfirmasi.
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => DeleteConfirmationDialog(
        title: title,
        message: message,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.error,
            size: AppDimensions.iconL,
          ),
          const SizedBox(width: AppDimensions.spacingS),
          Expanded(child: Text(title)),
        ],
      ),
      content: Text(
        message,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop(true);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.surface,
          ),
          child: const Text(AppStrings.delete),
        ),
      ],
    );
  }
}
