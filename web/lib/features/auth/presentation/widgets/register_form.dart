import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../cubit/register_cubit.dart';

/// Form register dengan field name, email, password, dan confirm password.
class RegisterForm extends StatefulWidget {
  /// Callback saat user tap "Sudah punya akun? Masuk".
  final VoidCallback? onLogin;

  const RegisterForm({
    super.key,
    this.onLogin,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildNameField(),
          const SizedBox(height: AppDimensions.spacingM),
          _buildEmailField(),
          const SizedBox(height: AppDimensions.spacingM),
          _buildPasswordField(),
          const SizedBox(height: AppDimensions.spacingM),
          _buildConfirmPasswordField(),
          const SizedBox(height: AppDimensions.spacingL),
          _buildRegisterButton(context),
          const SizedBox(height: AppDimensions.spacingM),
          _buildLoginLink(),
        ],
      ),
    );
  }

  Widget _buildNameField() => TextFormField(
        controller: _nameController,
        decoration: const InputDecoration(
          labelText: AppStrings.registerNameLabel,
          hintText: AppStrings.registerNameHint,
          prefixIcon: Icon(Icons.person_outline),
        ),
        textInputAction: TextInputAction.next,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return AppStrings.registerNameRequired;
          }
          return null;
        },
      );

  Widget _buildEmailField() => TextFormField(
        controller: _emailController,
        decoration: const InputDecoration(
          labelText: AppStrings.emailLabel,
          hintText: AppStrings.emailHint,
          prefixIcon: Icon(Icons.email_outlined),
        ),
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return AppStrings.emailRequired;
          }
          if (!value.contains('@')) {
            return AppStrings.emailInvalid;
          }
          return null;
        },
      );

  Widget _buildPasswordField() => TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          labelText: AppStrings.passwordLabel,
          hintText: AppStrings.passwordHint,
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () => setState(() {
              _obscurePassword = !_obscurePassword;
            }),
          ),
        ),
        textInputAction: TextInputAction.next,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return AppStrings.passwordRequired;
          }
          if (value.length < 8) {
            return AppStrings.passwordMinLength;
          }
          return null;
        },
      );

  Widget _buildConfirmPasswordField() => TextFormField(
        controller: _confirmPasswordController,
        obscureText: _obscureConfirmPassword,
        decoration: InputDecoration(
          labelText: AppStrings.userConfirmPasswordLabel,
          hintText: AppStrings.userConfirmPasswordHint,
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_off
                  : Icons.visibility,
            ),
            onPressed: () => setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            }),
          ),
        ),
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => _onSubmit(context),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return AppStrings.userConfirmPasswordRequired;
          }
          if (value != _passwordController.text) {
            return AppStrings.userPasswordMismatch;
          }
          return null;
        },
      );

  Widget _buildRegisterButton(BuildContext context) {
    final isLoading = context.watch<RegisterCubit>().state is RegisterLoading;

    return ElevatedButton(
      onPressed: isLoading ? null : () => _onSubmit(context),
      child: isLoading
          ? const SizedBox(
              height: AppDimensions.iconM,
              width: AppDimensions.iconM,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.surface,
              ),
            )
          : const Text(AppStrings.registerButton),
    );
  }

  Widget _buildLoginLink() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(AppStrings.hasAccount),
          TextButton(
            onPressed: widget.onLogin,
            child: const Text(AppStrings.backToLogin),
          ),
        ],
      );

  void _onSubmit(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<RegisterCubit>().register(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }
  }
}
