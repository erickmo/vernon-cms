import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../cubit/sidebar_cubit.dart';
import '../widgets/cms_sidebar.dart';
import '../widgets/cms_top_bar.dart';

/// Shell layout utama CMS.
///
/// Menyediakan sidebar + top bar yang membungkus semua halaman CMS.
/// Responsive: sidebar jadi drawer di layar kecil.
class CmsShellPage extends StatelessWidget {
  /// Child widget dari router.
  final Widget child;

  const CmsShellPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SidebarCubit>(),
      child: _CmsShellView(child: child),
    );
  }
}

class _CmsShellView extends StatelessWidget {
  final Widget child;

  const _CmsShellView({required this.child});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 768;

    return BlocBuilder<SidebarCubit, SidebarState>(
      buildWhen: (previous, current) =>
          previous.activeRoute != current.activeRoute ||
          previous.domains != current.domains,
      builder: (context, state) {
        final title = _getPageTitle(state.activeRoute);

        if (isDesktop) {
          return _buildDesktopLayout(title);
        }
        return _buildMobileLayout(title);
      },
    );
  }

  Widget _buildDesktopLayout(String title) => Scaffold(
        body: Row(
          children: [
            const CmsSidebar(),
            Expanded(
              child: Column(
                children: [
                  CmsTopBar(title: title),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildMobileLayout(String title) => Scaffold(
        drawer: const SizedBox(
          width: AppDimensions.sidebarWidth,
          child: CmsSidebar(),
        ),
        body: Column(
          children: [
            CmsTopBar(title: title),
            Expanded(child: child),
          ],
        ),
      );

  String _getPageTitle(String route) {
    switch (route) {
      case '/dashboard':
        return AppStrings.menuDashboard;
      case '/content':
        return AppStrings.menuContentList;
      case '/content-category':
        return AppStrings.menuContentCategory;
      case '/pages':
        return AppStrings.menuPageList;
      default:
        // Handle /domain/{slug} routes dynamically.
        if (route.startsWith('/domain/')) {
          final slug = route.replaceFirst('/domain/', '').split('/').first;
          return slug
              .split('-')
              .map((w) => w.isNotEmpty
                  ? '${w[0].toUpperCase()}${w.substring(1)}'
                  : '')
              .join(' ');
        }
        return '';
    }
  }
}
