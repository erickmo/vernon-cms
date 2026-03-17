import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Widget item menu sidebar — gaya MatDash white sidebar.
class CmsSidebarItem extends StatelessWidget {
  /// Icon menu.
  final IconData icon;

  /// Label menu.
  final String label;

  /// Apakah item ini aktif.
  final bool isActive;

  /// Apakah sidebar sedang collapsed.
  final bool isCollapsed;

  /// Callback saat item di-tap.
  final VoidCallback onTap;

  const CmsSidebarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isCollapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final child = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        hoverColor: AppColors.sidebarItemHover,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed
                ? AppDimensions.spacingS
                : AppDimensions.spacingM,
            vertical: AppDimensions.spacingS + 2,
          ),
          decoration: BoxDecoration(
            color: isActive ? AppColors.sidebarItemActiveBg : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          child: isCollapsed
              ? Center(
                  child: Icon(
                    icon,
                    color: isActive
                        ? AppColors.sidebarItemActive
                        : AppColors.sidebarText,
                    size: AppDimensions.iconM,
                  ),
                )
              : Row(
                  children: [
                    Icon(
                      icon,
                      color: isActive
                          ? AppColors.sidebarItemActive
                          : AppColors.sidebarText,
                      size: AppDimensions.iconM,
                    ),
                    const SizedBox(width: AppDimensions.spacingM),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isActive
                              ? AppColors.sidebarTextActive
                              : AppColors.sidebarText,
                          fontSize: 14,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );

    if (isCollapsed) {
      return Tooltip(message: label, child: child);
    }
    return child;
  }
}
