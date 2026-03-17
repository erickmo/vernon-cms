import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../../core/utils/jwt_decoder.dart';
import '../../../core/utils/role_guard.dart';
import '../../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../../features/domain_builder/domain/entities/domain_definition.dart';
import '../cubit/sidebar_cubit.dart';
import 'cms_sidebar_item.dart';
import 'cms_sidebar_section.dart';

/// Sidebar navigasi utama CMS — white sidebar gaya MatDash.
class CmsSidebar extends StatelessWidget {
  const CmsSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SidebarCubit, SidebarState>(
      builder: (context, state) {
        final width = state.isCollapsed
            ? AppDimensions.sidebarCollapsedWidth
            : AppDimensions.sidebarWidth;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: width,
          decoration: const BoxDecoration(
            color: AppColors.sidebarBackground,
            border: Border(
              right: BorderSide(color: AppColors.sidebarBorder),
            ),
          ),
          child: Column(
            children: [
              _buildBrandHeader(state.isCollapsed),
              const Divider(color: AppColors.divider, height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.spacingM,
                    horizontal: AppDimensions.spacingS,
                  ),
                  child: _buildMenuItems(context, state),
                ),
              ),
              const Divider(color: AppColors.divider, height: 1),
              _buildCollapseToggle(context, state.isCollapsed),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBrandHeader(bool isCollapsed) => SizedBox(
        height: AppDimensions.appBarHeight + 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingM,
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: const Icon(
                  Icons.dashboard_customize_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              if (!isCollapsed) ...[
                const SizedBox(width: AppDimensions.spacingS),
                Expanded(
                  child: Text(
                    AppConstants.appName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      );

  String? _getCurrentUserRole() {
    try {
      final token = getIt<AuthLocalDataSource>().getAccessToken();
      if (token == null) return null;
      return JwtDecoder.getRole(token);
    } catch (_) {
      return null;
    }
  }

  Widget _buildMenuItems(BuildContext context, SidebarState state) {
    final currentRole = _getCurrentUserRole();

    final domainsBySection = <String, List<DomainDefinition>>{};
    for (final domain in state.domains) {
      domainsBySection
          .putIfAbsent(domain.sidebarSection, () => [])
          .add(domain);
    }
    for (final list in domainsBySection.values) {
      list.sort((a, b) => a.sidebarOrder.compareTo(b.sidebarOrder));
    }

    List<Widget> contentDomainItems() => domainsBySection['content']
            ?.expand((d) => [
                  const SizedBox(height: AppDimensions.spacingXS),
                  CmsSidebarItem(
                    icon: _resolveIcon(d.icon),
                    label: d.pluralName,
                    isActive: state.activeRoute == '/domain/${d.slug}',
                    isCollapsed: state.isCollapsed,
                    onTap: () => _navigateTo(context, '/domain/${d.slug}'),
                  ),
                ])
            .toList() ??
        [];

    List<Widget> pageDomainItems() => domainsBySection['pages']
            ?.expand((d) => [
                  const SizedBox(height: AppDimensions.spacingXS),
                  CmsSidebarItem(
                    icon: _resolveIcon(d.icon),
                    label: d.pluralName,
                    isActive: state.activeRoute == '/domain/${d.slug}',
                    isCollapsed: state.isCollapsed,
                    onTap: () => _navigateTo(context, '/domain/${d.slug}'),
                  ),
                ])
            .toList() ??
        [];

    final knownSections = {'content', 'pages', 'settings'};
    final customSections =
        domainsBySection.keys.where((s) => !knownSections.contains(s)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Dashboard
        CmsSidebarItem(
          icon: Icons.space_dashboard_outlined,
          label: AppStrings.menuDashboard,
          isActive: state.activeRoute == '/dashboard',
          isCollapsed: state.isCollapsed,
          onTap: () => _navigateTo(context, '/dashboard'),
        ),
        const SizedBox(height: AppDimensions.spacingS),

        // Content Section
        CmsSidebarSection(
          title: AppStrings.sectionContent,
          isExpanded: state.expandedSections.contains('content'),
          isSidebarCollapsed: state.isCollapsed,
          onToggle: () =>
              context.read<SidebarCubit>().toggleSection('content'),
          children: [
            CmsSidebarItem(
              icon: Icons.article_outlined,
              label: AppStrings.menuContentList,
              isActive: state.activeRoute == '/content',
              isCollapsed: state.isCollapsed,
              onTap: () => _navigateTo(context, '/content'),
            ),
            const SizedBox(height: AppDimensions.spacingXS),
            CmsSidebarItem(
              icon: Icons.label_outlined,
              label: AppStrings.menuContentCategory,
              isActive: state.activeRoute == '/content-category',
              isCollapsed: state.isCollapsed,
              onTap: () => _navigateTo(context, '/content-category'),
            ),
            const SizedBox(height: AppDimensions.spacingXS),
            CmsSidebarItem(
              icon: Icons.perm_media_outlined,
              label: AppStrings.menuMedia,
              isActive: state.activeRoute == '/media',
              isCollapsed: state.isCollapsed,
              onTap: () => _navigateTo(context, '/media'),
            ),
            ...contentDomainItems(),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingXS),

        // Pages Section
        CmsSidebarSection(
          title: AppStrings.sectionPages,
          isExpanded: state.expandedSections.contains('pages'),
          isSidebarCollapsed: state.isCollapsed,
          onToggle: () =>
              context.read<SidebarCubit>().toggleSection('pages'),
          children: [
            CmsSidebarItem(
              icon: Icons.web_outlined,
              label: AppStrings.menuPageList,
              isActive: state.activeRoute == '/pages',
              isCollapsed: state.isCollapsed,
              onTap: () => _navigateTo(context, '/pages'),
            ),
            ...pageDomainItems(),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingXS),

        // Custom domain sections
        ...customSections.expand((section) {
          final domains = domainsBySection[section]!;
          return [
            CmsSidebarSection(
              title: section,
              isExpanded: state.expandedSections.contains(section),
              isSidebarCollapsed: state.isCollapsed,
              onToggle: () =>
                  context.read<SidebarCubit>().toggleSection(section),
              children: domains
                  .expand((d) => [
                        CmsSidebarItem(
                          icon: _resolveIcon(d.icon),
                          label: d.pluralName,
                          isActive:
                              state.activeRoute == '/domain/${d.slug}',
                          isCollapsed: state.isCollapsed,
                          onTap: () =>
                              _navigateTo(context, '/domain/${d.slug}'),
                        ),
                        const SizedBox(height: AppDimensions.spacingXS),
                      ])
                  .toList(),
            ),
            const SizedBox(height: AppDimensions.spacingXS),
          ];
        }),

        // Settings Section
        CmsSidebarSection(
          title: AppStrings.sectionSettings,
          isExpanded: state.expandedSections.contains('settings'),
          isSidebarCollapsed: state.isCollapsed,
          onToggle: () =>
              context.read<SidebarCubit>().toggleSection('settings'),
          children: [
            CmsSidebarItem(
              icon: Icons.device_hub_outlined,
              label: AppStrings.menuDomainBuilder,
              isActive: state.activeRoute == '/domain-builder',
              isCollapsed: state.isCollapsed,
              onTap: () => _navigateTo(context, '/domain-builder'),
            ),
            if (RoleGuard.canManageUsers(currentRole)) ...[
              const SizedBox(height: AppDimensions.spacingXS),
              CmsSidebarItem(
                icon: Icons.people_alt_outlined,
                label: AppStrings.menuUserManagement,
                isActive: state.activeRoute == '/users',
                isCollapsed: state.isCollapsed,
                onTap: () => _navigateTo(context, '/users'),
              ),
            ],
            const SizedBox(height: AppDimensions.spacingXS),
            CmsSidebarItem(
              icon: Icons.tune_outlined,
              label: AppStrings.menuSettings,
              isActive: state.activeRoute == '/settings',
              isCollapsed: state.isCollapsed,
              onTap: () => _navigateTo(context, '/settings'),
            ),
            const SizedBox(height: AppDimensions.spacingXS),
            CmsSidebarItem(
              icon: Icons.history_rounded,
              label: AppStrings.menuActivityLog,
              isActive: state.activeRoute == '/activity-logs',
              isCollapsed: state.isCollapsed,
              onTap: () => _navigateTo(context, '/activity-logs'),
            ),
            const SizedBox(height: AppDimensions.spacingXS),
            CmsSidebarItem(
              icon: Icons.vpn_key_outlined,
              label: AppStrings.menuApiToken,
              isActive: state.activeRoute == '/api-tokens',
              isCollapsed: state.isCollapsed,
              onTap: () => _navigateTo(context, '/api-tokens'),
            ),
          ],
        ),
      ],
    );
  }

  IconData _resolveIcon(String? iconName) {
    if (iconName == null || iconName.isEmpty) return Icons.folder_outlined;
    const iconMap = <String, IconData>{
      'store': Icons.store_outlined,
      'people': Icons.people_outlined,
      'person': Icons.person_outlined,
      'business': Icons.business_outlined,
      'inventory': Icons.inventory_outlined,
      'shopping_cart': Icons.shopping_cart_outlined,
      'local_shipping': Icons.local_shipping_outlined,
      'category': Icons.category_outlined,
      'event': Icons.event_outlined,
      'location': Icons.location_on_outlined,
      'settings': Icons.settings_outlined,
      'star': Icons.star_outlined,
      'favorite': Icons.favorite_outlined,
      'bookmark': Icons.bookmark_outlined,
      'folder': Icons.folder_outlined,
      'description': Icons.description_outlined,
      'assignment': Icons.assignment_outlined,
      'work': Icons.work_outlined,
      'school': Icons.school_outlined,
      'medical_services': Icons.medical_services_outlined,
      'restaurant': Icons.restaurant_outlined,
      'hotel': Icons.hotel_outlined,
      'flight': Icons.flight_outlined,
      'directions_car': Icons.directions_car_outlined,
      'home': Icons.home_outlined,
      'apartment': Icons.apartment_outlined,
      'attach_money': Icons.attach_money,
      'payment': Icons.payment_outlined,
      'receipt': Icons.receipt_outlined,
      'analytics': Icons.analytics_outlined,
      'dashboard': Icons.dashboard_outlined,
      'build': Icons.build_outlined,
      'extension': Icons.extension_outlined,
    };
    return iconMap[iconName] ?? Icons.folder_outlined;
  }

  Widget _buildCollapseToggle(BuildContext context, bool isCollapsed) =>
      InkWell(
        onTap: () => context.read<SidebarCubit>().toggleCollapse(),
        child: SizedBox(
          height: AppDimensions.buttonHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isCollapsed
                    ? Icons.keyboard_arrow_right_rounded
                    : Icons.keyboard_arrow_left_rounded,
                color: AppColors.textHint,
                size: 22,
              ),
            ],
          ),
        ),
      );

  void _navigateTo(BuildContext context, String route) {
    context.read<SidebarCubit>().selectRoute(route);
    context.go(route);
  }
}
