import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/activity_log.dart';

/// Item tunggal dalam timeline log aktivitas.
class ActivityLogItem extends StatelessWidget {
  /// Data log aktivitas.
  final ActivityLog log;

  const ActivityLogItem({
    super.key,
    required this.log,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingS),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(),
            const SizedBox(width: AppDimensions.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  if (log.entityTitle != null) ...[
                    const SizedBox(height: AppDimensions.spacingXS),
                    _buildEntityInfo(context),
                  ],
                  if (log.details != null &&
                      log.details!.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spacingXS),
                    Text(
                      log.details!,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.spacingS),
            Text(
              _formatRelativeTime(log.createdAt),
              style: const TextStyle(
                color: AppColors.textHint,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (log.userAvatarUrl != null && log.userAvatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: AppDimensions.avatarS,
        backgroundImage: NetworkImage(log.userAvatarUrl!),
      );
    }
    return CircleAvatar(
      radius: AppDimensions.avatarS,
      backgroundColor: AppColors.primary,
      child: Text(
        log.userName.isNotEmpty ? log.userName[0].toUpperCase() : '?',
        style: const TextStyle(
          color: AppColors.surface,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Text(
          log.userName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingS),
        _buildActionBadge(),
      ],
    );
  }

  Widget _buildActionBadge() {
    final color = _getActionColor(log.action);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingS,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        log.action,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEntityInfo(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingXS,
            vertical: 1,
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          child: Text(
            log.entityType,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.spacingXS),
        Expanded(
          child: Text(
            log.entityTitle ?? '',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'created':
        return AppColors.success;
      case 'updated':
        return AppColors.info;
      case 'deleted':
        return AppColors.error;
      case 'login':
        return AppColors.primary;
      case 'logout':
        return AppColors.textSecondary;
      case 'published':
        return AppColors.success;
      case 'archived':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks minggu lalu';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months bulan lalu';
    }
  }
}
