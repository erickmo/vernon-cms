import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/client/presentation/pages/client_detail_page.dart';
import '../../features/client/presentation/pages/client_form_page.dart';
import '../../features/client/presentation/pages/client_list_page.dart';
import '../../features/payment/presentation/pages/payment_detail_page.dart';
import '../../features/payment/presentation/pages/payment_form_page.dart';
import '../../features/payment/presentation/pages/payment_list_page.dart';
import '../../shared/presentation/pages/admin_shell_page.dart';
import '../constants/app_constants.dart';
import '../di/injection.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/clients',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final prefs = getIt<SharedPreferences>();
      final token = prefs.getString(AppConstants.accessTokenKey);
      final isLoginPage = state.matchedLocation == '/login';
      if (token == null && !isLoginPage) return '/login';
      if (token != null && isLoginPage) return '/clients';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => AdminShellPage(child: child),
        routes: [
          // Clients
          GoRoute(
            path: '/clients',
            builder: (context, state) => const ClientListPage(),
          ),
          GoRoute(
            path: '/clients/create',
            builder: (context, state) => const ClientFormPage(),
          ),
          GoRoute(
            path: '/clients/:id',
            builder: (context, state) => ClientDetailPage(
              clientId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/clients/:id/edit',
            builder: (context, state) => ClientFormPage(
              clientId: state.pathParameters['id'],
            ),
          ),
          // Payments
          GoRoute(
            path: '/payments',
            builder: (context, state) => const PaymentListPage(),
          ),
          GoRoute(
            path: '/payments/create',
            builder: (context, state) => const PaymentFormPage(),
          ),
          GoRoute(
            path: '/payments/:id',
            builder: (context, state) => PaymentDetailPage(
              paymentId: state.pathParameters['id']!,
            ),
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
