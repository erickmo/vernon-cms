import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/cms_user.dart';
import '../cubit/user_form_cubit.dart';

/// Halaman form user untuk membuat atau mengedit user.
///
/// Create: email, name, role, password.
/// Edit: email, name, role, is_active.
class UserFormPage extends StatelessWidget {
  /// ID user yang akan diedit. Null jika membuat baru.
  final String? userId;

  const UserFormPage({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<UserFormCubit>();
        if (userId != null) {
          cubit.loadUser(userId!);
        }
        return cubit;
      },
      child: _UserFormView(userId: userId),
    );
  }
}

class _UserFormView extends StatefulWidget {
  final String? userId;

  const _UserFormView({this.userId});

  @override
  State<_UserFormView> createState() => _UserFormViewState();
}

class _UserFormViewState extends State<_UserFormView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _emailController;
  late final TextEditingController _nameController;
  late final TextEditingController _passwordController;

  String _role = 'editor';
  bool _isActive = true;
  bool _initialized = false;

  bool get _isEditing => widget.userId != null;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _nameController = TextEditingController();
    _passwordController = TextEditingController();

    if (!_isEditing) {
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _populateFields(CmsUser user) {
    _emailController.text = user.email;
    _nameController.text = user.name;
    _role = user.role;
    _isActive = user.isActive;
  }

  CmsUser _buildUserEntity({CmsUser? existing}) {
    final now = DateTime.now();
    return CmsUser(
      id: existing?.id ?? '',
      email: _emailController.text.trim(),
      name: _nameController.text.trim(),
      role: _role,
      isActive: _isActive,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<UserFormCubit>();
    final state = cubit.state;
    final existing = state is UserFormLoaded ? state.user : null;

    final user = _buildUserEntity(existing: existing);

    final success = _isEditing
        ? await cubit.updateUser(user)
        : await cubit.createUser(
            user,
            passwordHash: _passwordController.text,
          );

    if (success && mounted) {
      context.go('/users');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserFormCubit, UserFormState>(
      listener: _onFormStateChanged,
      builder: (context, state) {
        return state.when(
          initial: () => _buildForm(context),
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: (user) {
            if (!_initialized) {
              _initialized = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _populateFields(user);
                  });
                }
              });
            }
            return _buildForm(context);
          },
          saving: () => _buildForm(context, isSaving: true),
          saved: () => _buildForm(context),
          error: (message) => _buildForm(context),
        );
      },
    );
  }

  void _onFormStateChanged(BuildContext context, UserFormState state) {
    state.whenOrNull(
      error: (message) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
        ),
      ),
      saved: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? AppStrings.userUpdated : AppStrings.userCreated,
          ),
          backgroundColor: AppColors.success,
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, {bool isSaving = false}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, isSaving),
            const SizedBox(height: AppDimensions.spacingL),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.spacingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          AppStrings.userInfoSection,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingM),
                        _buildEmailField(),
                        const SizedBox(height: AppDimensions.spacingM),
                        _buildNameField(),
                        const SizedBox(height: AppDimensions.spacingM),
                        _buildRoleDropdown(),
                        const SizedBox(height: AppDimensions.spacingM),
                        if (_isEditing) _buildActiveSwitch(),
                        if (!_isEditing) ...[
                          _buildPasswordField(),
                          const SizedBox(height: AppDimensions.spacingM),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isSaving) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => context.go('/users'),
              icon: const Icon(Icons.arrow_back),
              tooltip: AppStrings.back,
            ),
            const SizedBox(width: AppDimensions.spacingS),
            Text(
              _isEditing ? AppStrings.userEdit : AppStrings.userAdd,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: isSaving ? null : _onSave,
          child: isSaving
              ? const SizedBox(
                  width: AppDimensions.iconS,
                  height: AppDimensions.iconS,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(AppStrings.save),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: const InputDecoration(
        labelText: AppStrings.emailLabel,
        hintText: AppStrings.emailHint,
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return AppStrings.emailRequired;
        }
        return null;
      },
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: AppStrings.userNameLabel,
        hintText: AppStrings.userNameHint,
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return AppStrings.userNameRequired;
        }
        return null;
      },
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _role,
      decoration: const InputDecoration(
        labelText: AppStrings.userRoleLabel,
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'admin', child: Text('Admin')),
        DropdownMenuItem(value: 'editor', child: Text('Editor')),
        DropdownMenuItem(value: 'viewer', child: Text('Viewer')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _role = value);
        }
      },
    );
  }

  Widget _buildActiveSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          AppStrings.userActiveLabel,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Switch(
          value: _isActive,
          onChanged: (value) => setState(() => _isActive = value),
          activeThumbColor: AppColors.success,
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      decoration: const InputDecoration(
        labelText: AppStrings.passwordLabel,
        hintText: AppStrings.passwordHint,
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (!_isEditing && (value == null || value.trim().isEmpty)) {
          return AppStrings.passwordRequired;
        }
        return null;
      },
    );
  }
}
