import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Widget section (grup) menu sidebar — gaya MatDash.
class CmsSidebarSection extends StatelessWidget {
  /// Judul section.
  final String title;

  /// Apakah section ini expanded.
  final bool isExpanded;

  /// Apakah sidebar sedang collapsed.
  final bool isSidebarCollapsed;

  /// Callback saat section header di-tap.
  final VoidCallback onToggle;

  /// Item-item di dalam section.
  final List<Widget> children;

  const CmsSidebarSection({
    super.key,
    required this.title,
    required this.isExpanded,
    required this.isSidebarCollapsed,
    required this.onToggle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    if (isSidebarCollapsed) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.spacingS,
              horizontal: AppDimensions.spacingS,
            ),
            child: Container(
              height: 1,
              color: AppColors.divider,
            ),
          ),
          ...children,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spacingXS),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }

  Widget _buildSectionHeader() => InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingM,
            vertical: AppDimensions.spacingS,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.sidebarSectionTitle,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: AppColors.sidebarSectionTitle,
                size: AppDimensions.iconS,
              ),
            ],
          ),
        ),
      );
}
