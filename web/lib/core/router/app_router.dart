import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/content/presentation/pages/content_category_page.dart';
import '../../features/content/presentation/pages/content_form_page.dart';
import '../../features/content/presentation/pages/content_list_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/page_management/presentation/pages/page_form_page.dart';
import '../../features/page_management/presentation/pages/page_list_page.dart';
import '../../features/domain_builder/presentation/pages/domain_builder_list_page.dart';
import '../../features/domain_builder/presentation/pages/domain_builder_form_page.dart';
import '../../features/domain_records/presentation/pages/domain_record_list_page.dart';
import '../../features/domain_records/presentation/pages/domain_record_form_page.dart';
import '../../features/media/presentation/pages/media_list_page.dart';
import '../../features/user_management/presentation/pages/user_form_page.dart';
import '../../features/user_management/presentation/pages/user_list_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/activity_log/presentation/pages/activity_log_page.dart';
import '../../features/api_token/presentation/pages/api_token_page.dart';
import '../../shared/presentation/pages/cms_shell_page.dart';

/// Router aplikasi menggunakan go_router.
/// Semua route didefinisikan di sini.
class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    routes: [
      // Auth routes (tanpa shell CMS)
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      // CMS Shell — sidebar + topbar membungkus semua halaman
      ShellRoute(
        builder: (context, state, child) => CmsShellPage(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/content',
            builder: (context, state) => const ContentListPage(),
          ),
          GoRoute(
            path: '/content/create',
            builder: (context, state) => const ContentFormPage(),
          ),
          GoRoute(
            path: '/content/:id/edit',
            builder: (context, state) => ContentFormPage(
              contentId: state.pathParameters['id'],
            ),
          ),
          GoRoute(
            path: '/content-category',
            builder: (context, state) => const ContentCategoryPage(),
          ),
          GoRoute(
            path: '/media',
            builder: (context, state) => const MediaListPage(),
          ),
          GoRoute(
            path: '/pages',
            builder: (context, state) => const PageListPage(),
          ),
          GoRoute(
            path: '/pages/create',
            builder: (context, state) => const PageFormPage(),
          ),
          GoRoute(
            path: '/pages/:id/edit',
            builder: (context, state) => PageFormPage(
              pageId: state.pathParameters['id'],
            ),
          ),
          GoRoute(
            path: '/users',
            builder: (context, state) => const UserListPage(),
          ),
          GoRoute(
            path: '/users/create',
            builder: (context, state) => const UserFormPage(),
          ),
          GoRoute(
            path: '/users/:id/edit',
            builder: (context, state) => UserFormPage(
              userId: state.pathParameters['id'],
            ),
          ),
          GoRoute(
            path: '/domain-builder',
            builder: (context, state) => const DomainBuilderListPage(),
          ),
          GoRoute(
            path: '/domain-builder/create',
            builder: (context, state) => const DomainBuilderFormPage(),
          ),
          GoRoute(
            path: '/domain-builder/:id/edit',
            builder: (context, state) => DomainBuilderFormPage(
              domainId: state.pathParameters['id'],
            ),
          ),
          GoRoute(
            path: '/domain/:slug',
            builder: (context, state) => DomainRecordListPage(
              slug: state.pathParameters['slug']!,
            ),
          ),
          GoRoute(
            path: '/domain/:slug/create',
            builder: (context, state) => DomainRecordFormPage(
              slug: state.pathParameters['slug']!,
            ),
          ),
          GoRoute(
            path: '/domain/:slug/:id/edit',
            builder: (context, state) => DomainRecordFormPage(
              slug: state.pathParameters['slug']!,
              recordId: state.pathParameters['id'],
            ),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: '/activity-logs',
            builder: (context, state) => const ActivityLogPage(),
          ),
          GoRoute(
            path: '/api-tokens',
            builder: (context, state) => const ApiTokenPage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Halaman tidak ditemukan: ${state.error}'),
      ),
    ),
  );
}
