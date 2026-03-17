import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Widget kartu statistik untuk dashboard.
///
/// Menampilkan icon, judul, nilai utama, dan opsional growth indicator.
class StatsCard extends StatelessWidget {
  /// Icon kartu.
  final IconData icon;

  /// Warna background icon.
  final Color iconColor;

  /// Judul statistik.
  final String title;

  /// Nilai utama (angka besar).
  final String value;

  /// Subtitle opsional.
  final String? subtitle;

  /// Persentase pertumbuhan (opsional, tampil dengan warna hijau/merah).
  final double? growthPercent;

  const StatsCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    this.subtitle,
    this.growthPercent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppDimensions.spacingM),
            _buildValue(),
            if (growthPercent != null || subtitle != null)
              _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingS),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Icon(icon, color: iconColor, size: AppDimensions.iconM),
          ),
          const SizedBox(width: AppDimensions.spacingS),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      );

  Widget _buildValue() => Text(
        value,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      );

  Widget _buildFooter() => Padding(
        padding: const EdgeInsets.only(top: AppDimensions.spacingS),
        child: Row(
          children: [
            if (growthPercent != null) _buildGrowthBadge(),
            if (subtitle != null) ...[
              if (growthPercent != null)
                const SizedBox(width: AppDimensions.spacingS),
              Expanded(
                child: Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      );

  Widget _buildGrowthBadge() {
    final isPositive = growthPercent! >= 0;
    final color = isPositive ? AppColors.success : AppColors.error;
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;
    final sign = isPositive ? '+' : '';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingS,
        vertical: AppDimensions.spacingXS,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 2),
          Text(
            '$sign${growthPercent!.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
