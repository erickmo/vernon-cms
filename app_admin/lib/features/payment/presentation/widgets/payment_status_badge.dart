import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/payment.dart';

class PaymentStatusBadge extends StatelessWidget {
  final PaymentStatus status;

  const PaymentStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = switch (status) {
      PaymentStatus.paid => (AppStrings.filterPaid, AppColors.paid, AppColors.paidBg),
      PaymentStatus.pending => (AppStrings.filterPending, AppColors.pending, AppColors.pendingBg),
      PaymentStatus.failed => (AppStrings.filterFailed, AppColors.failed, AppColors.failedBg),
      PaymentStatus.cancelled => (AppStrings.filterCancelled, AppColors.cancelled, AppColors.cancelledBg),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingS,
        vertical: AppDimensions.spacingXS,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
