import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../cubit/login_cubit.dart';

/// Form login dengan field email, password, remember me, dan link ke register.
class LoginForm extends StatefulWidget {
  /// Callback saat user tap "Daftar Akun Baru".
  final VoidCallback? onRegister;

  /// Email yang sudah tersimpan dari remember me.
  final String initialEmail;

  /// Apakah remember me aktif dari sebelumnya.
  final bool initialRememberMe;

  const LoginForm({
    super.key,
    this.onRegister,
    this.initialEmail = '',
    this.initialRememberMe = false,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late bool _rememberMe;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(
      text: widget.initialEmail.isNotEmpty
          ? widget.initialEmail
          : 'admin@vernon.com',
    );
    _passwordController = TextEditingController(text: 'admin12345');
    _rememberMe = widget.initialRememberMe;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildEmailField(),
          const SizedBox(height: AppDimensions.spacingM),
          _buildPasswordField(),
          const SizedBox(height: AppDimensions.spacingS),
          _buildRememberMe(),
          const SizedBox(height: AppDimensions.spacingL),
          _buildLoginButton(context),
          const SizedBox(height: AppDimensions.spacingM),
          _buildRegisterLink(),
        ],
      ),
    );
  }

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
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => _onSubmit(context),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return AppStrings.passwordRequired;
          }
          return null;
        },
      );

  Widget _buildRememberMe() => Row(
        children: [
          SizedBox(
            height: AppDimensions.buttonHeightS,
            child: Checkbox(
              value: _rememberMe,
              onChanged: (value) => setState(() {
                _rememberMe = value ?? false;
              }),
            ),
          ),
          const Text(AppStrings.rememberMe),
        ],
      );

  Widget _buildLoginButton(BuildContext context) {
    final isLoading = context.watch<LoginCubit>().state is LoginLoading;

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
          : const Text(AppStrings.loginButton),
    );
  }

  Widget _buildRegisterLink() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(AppStrings.noAccount),
          TextButton(
            onPressed: widget.onRegister,
            child: const Text(AppStrings.registerLink),
          ),
        ],
      );

  void _onSubmit(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<LoginCubit>().login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            rememberMe: _rememberMe,
          );
    }
  }
}
