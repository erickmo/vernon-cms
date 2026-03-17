import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../../core/utils/jwt_decoder.dart';
import '../../../features/auth/data/datasources/auth_local_datasource.dart';

/// Top bar CMS — gaya MatDash dengan search, notifikasi, dan user menu.
class CmsTopBar extends StatelessWidget {
  /// Judul halaman saat ini.
  final String title;

  const CmsTopBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.appBarHeight + 8,
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingL),
      child: Row(
        children: [
          _buildMenuButton(context),
          if (title.isNotEmpty) ...[
            _buildTitle(),
          ],
          const Spacer(),
          _buildSearch(),
          const SizedBox(width: AppDimensions.spacingS),
          _buildNotificationButton(),
          const SizedBox(width: AppDimensions.spacingS),
          _buildUserSection(context),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 768) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(right: AppDimensions.spacingS),
      child: IconButton(
        icon: const Icon(Icons.menu_rounded),
        color: AppColors.textSecondary,
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
    );
  }

  Widget _buildTitle() => Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: -0.2,
        ),
      );

  Widget _buildSearch() => SizedBox(
        width: 220,
        height: 38,
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: const TextStyle(
              fontSize: 13,
              color: AppColors.textHint,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              size: 18,
              color: AppColors.textHint,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingM,
              vertical: 0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            filled: true,
            fillColor: AppColors.background,
          ),
          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
        ),
      );

  Widget _buildNotificationButton() => Badge(
        label: const Text(
          '2',
          style: TextStyle(fontSize: 10, color: Colors.white),
        ),
        backgroundColor: AppColors.error,
        offset: const Offset(-4, 4),
        child: IconButton(
          icon: const Icon(Icons.notifications_outlined),
          color: AppColors.textSecondary,
          iconSize: 22,
          tooltip: 'Notifikasi',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notifikasi akan segera tersedia'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      );

  Widget _buildUserSection(BuildContext context) {
    final localDataSource = getIt<AuthLocalDataSource>();
    final accessToken = localDataSource.getAccessToken();

    String displayName = 'User';
    String email = '';
    String role = '';
    String initial = 'U';

    if (accessToken != null) {
      final emailVal = JwtDecoder.getEmail(accessToken);
      final roleVal = JwtDecoder.getRole(accessToken);
      if (emailVal != null && emailVal.isNotEmpty) {
        email = emailVal;
        displayName = emailVal.split('@').first;
        initial = emailVal[0].toUpperCase();
      }
      if (roleVal != null) {
        role = roleVal;
      }
    }

    return PopupMenuButton<String>(
      offset: const Offset(0, 52),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        side: const BorderSide(color: AppColors.divider),
      ),
      elevation: 8,
      shadowColor: Colors.black12,
      onSelected: (value) {
        if (value == 'logout') _handleLogout(context);
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: _buildUserMenuHeader(displayName, email, role, initial),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
              SizedBox(width: AppDimensions.spacingS),
              Text(
                AppStrings.logout,
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
      child: _buildUserChip(displayName, role, initial),
    );
  }

  Widget _buildUserChip(String name, String role, String initial) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingS),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (role.isNotEmpty)
                Text(
                  role,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppDimensions.spacingXS),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textHint,
            size: 18,
          ),
        ],
      );

  Widget _buildUserMenuHeader(
    String name,
    String email,
    String role,
    String initial,
  ) =>
      Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              initial,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                Text(
                  email,
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (role.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      role,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      );

  void _handleLogout(BuildContext context) {
    getIt<AuthLocalDataSource>().clearTokens();
    context.go('/login');
  }
}
