import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';

/// Halaman lupa password.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spacingL),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: _submitted ? _buildSuccessContent() : _buildFormContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent() => Card(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingL),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.lock_reset,
                  size: AppDimensions.avatarL,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppDimensions.spacingM),
                const Text(
                  AppStrings.forgotPasswordTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingS),
                const Text(
                  AppStrings.forgotPasswordSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingL),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.emailLabel,
                    hintText: AppStrings.emailHint,
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppStrings.emailRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.spacingL),
                ElevatedButton(
                  onPressed: _onSubmit,
                  child: const Text(AppStrings.sendResetLink),
                ),
                const SizedBox(height: AppDimensions.spacingM),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text(AppStrings.backToLogin),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildSuccessContent() => Card(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: AppDimensions.avatarL,
                color: AppColors.success,
              ),
              const SizedBox(height: AppDimensions.spacingM),
              const Text(
                AppStrings.resetLinkSent,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingS),
              const Text(
                AppStrings.resetLinkSentSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingL),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text(AppStrings.backToLogin),
              ),
            ],
          ),
        ),
      );

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _submitted = true);
    }
  }
}
