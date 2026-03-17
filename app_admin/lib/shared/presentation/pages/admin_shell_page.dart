import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../../features/auth/domain/usecases/logout_usecase.dart';

class AdminShellPage extends StatelessWidget {
  final Widget child;
  const AdminShellPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _Sidebar(),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final _navItems = const [
    _NavItem(
      icon: Icons.people_outline,
      label: AppStrings.menuClients,
      path: '/clients',
    ),
    _NavItem(
      icon: Icons.receipt_long_outlined,
      label: AppStrings.menuPayments,
      path: '/payments',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    return Container(
      width: AppDimensions.sidebarWidth,
      color: AppColors.sidebarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLogo(context),
          const SizedBox(height: AppDimensions.spacingS),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingS,
                vertical: AppDimensions.spacingXS,
              ),
              children: _navItems.map((item) {
                final isActive = location.startsWith(item.path);
                return _buildNavItem(context, item, isActive);
              }).toList(),
            ),
          ),
          _buildLogout(context),
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Container(
      height: AppDimensions.topbarHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
      ),
      child: Row(
        children: [
          const Icon(Icons.admin_panel_settings_rounded,
              color: Colors.white, size: AppDimensions.iconL),
          const SizedBox(width: AppDimensions.spacingS),
          Text(
            AppStrings.loginTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, _NavItem item, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingXS),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.sidebarActive.withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: isActive
            ? Border.all(
                color: AppColors.sidebarActive.withValues(alpha: 0.3))
            : null,
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          item.icon,
          color: isActive ? AppColors.sidebarActive : AppColors.sidebarText,
          size: AppDimensions.iconM,
        ),
        title: Text(
          item.label,
          style: TextStyle(
            color:
                isActive ? AppColors.sidebarActive : AppColors.sidebarText,
            fontWeight:
                isActive ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        onTap: () => context.go(item.path),
      ),
    );
  }

  Widget _buildLogout(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingS),
      child: ListTile(
        dense: true,
        leading: const Icon(Icons.logout,
            color: AppColors.sidebarText, size: AppDimensions.iconM),
        title: const Text(
          AppStrings.logout,
          style: TextStyle(color: AppColors.sidebarText, fontSize: 14),
        ),
        onTap: () async {
          await getIt<LogoutUseCase>()();
          if (context.mounted) context.go('/login');
        },
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String path;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.path,
  });
}
