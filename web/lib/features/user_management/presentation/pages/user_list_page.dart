import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../content/presentation/widgets/delete_confirmation_dialog.dart';
import '../../domain/entities/cms_user.dart';
import '../cubit/user_list_cubit.dart';
import '../widgets/user_table.dart';

/// Halaman daftar user (admin only).
class UserListPage extends StatelessWidget {
  const UserListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<UserListCubit>()..loadUsers(),
      child: const _UserListView(),
    );
  }
}

class _UserListView extends StatefulWidget {
  const _UserListView();

  @override
  State<_UserListView> createState() => _UserListViewState();
}

class _UserListViewState extends State<_UserListView> {
  final _searchController = TextEditingController();
  String _roleFilter = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserListCubit, UserListState>(
      listener: _onStateChanged,
      builder: (context, state) => state.when(
        initial: () => const SizedBox.shrink(),
        loading: () => const Center(child: CircularProgressIndicator()),
        loaded: (users, searchQuery, roleFilter) =>
            _buildContent(context, users),
        error: (message) => _buildError(context, message),
      ),
    );
  }

  void _onStateChanged(BuildContext context, UserListState state) {
    state.whenOrNull(
      error: (message) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<CmsUser> users) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: AppDimensions.spacingL),
          _buildFilterBar(context),
          const SizedBox(height: AppDimensions.spacingM),
          UserTable(
            users: users,
            onEdit: (user) => context.go('/users/${user.id}/edit'),
            onDelete: (user) => _showDeleteDialog(context, user),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          AppStrings.userManagementTitle,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => context.go('/users/create'),
          icon: const Icon(Icons.add),
          label: const Text(AppStrings.userAdd),
        ),
      ],
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.spacingM,
      runSpacing: AppDimensions.spacingM,
      children: [
        SizedBox(
          width: 280,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: AppStrings.userSearch,
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _applyFilters(context);
                      },
                    )
                  : null,
            ),
            onSubmitted: (_) => _applyFilters(context),
          ),
        ),
        SizedBox(
          width: 180,
          child: DropdownButtonFormField<String>(
            initialValue: _roleFilter.isEmpty ? null : _roleFilter,
            decoration: const InputDecoration(
              labelText: AppStrings.userRoleLabel,
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: null,
                child: Text(AppStrings.userAllRoles),
              ),
              DropdownMenuItem(
                value: 'admin',
                child: Text('Admin'),
              ),
              DropdownMenuItem(
                value: 'editor',
                child: Text('Editor'),
              ),
              DropdownMenuItem(
                value: 'viewer',
                child: Text('Viewer'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _roleFilter = value ?? '';
              });
              _applyFilters(context);
            },
          ),
        ),
      ],
    );
  }

  void _applyFilters(BuildContext context) {
    final search = _searchController.text.trim();

    context.read<UserListCubit>().loadUsers(
          search: search.isNotEmpty ? search : null,
          role: _roleFilter.isNotEmpty ? _roleFilter : null,
        );
  }

  void _showDeleteDialog(BuildContext context, CmsUser user) {
    final cubit = context.read<UserListCubit>();
    DeleteConfirmationDialog.show(
      context: context,
      title: AppStrings.userDelete,
      message: '${AppStrings.userDeleteConfirm} "${user.name}"?',
      onConfirm: () => cubit.deleteUser(user.id),
    );
  }

  Widget _buildError(BuildContext context, String message) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: AppDimensions.avatarL,
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              message,
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            ElevatedButton(
              onPressed: () =>
                  context.read<UserListCubit>().loadUsers(),
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      );
}
