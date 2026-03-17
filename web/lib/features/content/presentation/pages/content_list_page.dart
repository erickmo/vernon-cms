import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/content.dart';
import '../cubit/content_list_cubit.dart';
import '../widgets/content_table.dart';
import '../widgets/delete_confirmation_dialog.dart';

/// Halaman daftar konten.
class ContentListPage extends StatelessWidget {
  const ContentListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ContentListCubit>()..loadContents(),
      child: const _ContentListView(),
    );
  }
}

class _ContentListView extends StatefulWidget {
  const _ContentListView();

  @override
  State<_ContentListView> createState() => _ContentListViewState();
}

class _ContentListViewState extends State<_ContentListView> {
  final _searchController = TextEditingController();
  String _statusFilter = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContentListCubit, ContentListState>(
      listener: _onStateChanged,
      builder: (context, state) => state.when(
        initial: () => const SizedBox.shrink(),
        loading: () => const Center(child: CircularProgressIndicator()),
        loaded: (contents, searchQuery, statusFilter) =>
            _buildContent(context, contents),
        error: (message) => _buildError(context, message),
      ),
    );
  }

  void _onStateChanged(BuildContext context, ContentListState state) {
    state.whenOrNull(
      error: (message) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Content> contents) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: AppDimensions.spacingL),
          _buildFilterBar(context),
          const SizedBox(height: AppDimensions.spacingM),
          ContentTable(
            contents: contents,
            onEdit: (content) => context.go('/content/${content.id}/edit'),
            onDelete: (content) => _showDeleteDialog(context, content),
            onPublish: (content) =>
                context.read<ContentListCubit>().publishContent(content.id),
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
          AppStrings.contentListTitle,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => context.go('/content/create'),
          icon: const Icon(Icons.add),
          label: const Text(AppStrings.addContent),
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
              hintText: AppStrings.searchContent,
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
            initialValue: _statusFilter.isEmpty ? null : _statusFilter,
            decoration: const InputDecoration(
              labelText: AppStrings.contentStatus,
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: null,
                child: Text(AppStrings.contentAllStatuses),
              ),
              DropdownMenuItem(
                value: 'draft',
                child: Text(AppStrings.contentStatusDraft),
              ),
              DropdownMenuItem(
                value: 'published',
                child: Text(AppStrings.contentStatusPublished),
              ),
              DropdownMenuItem(
                value: 'archived',
                child: Text(AppStrings.contentStatusArchived),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _statusFilter = value ?? '';
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
    context.read<ContentListCubit>().loadContents(
          search: search.isNotEmpty ? search : null,
          status: _statusFilter.isNotEmpty ? _statusFilter : null,
        );
  }

  void _showDeleteDialog(BuildContext context, Content content) {
    final cubit = context.read<ContentListCubit>();
    DeleteConfirmationDialog.show(
      context: context,
      title: AppStrings.deleteContent,
      message: '${AppStrings.deleteContentConfirm} "${content.title}"?',
      onConfirm: () => cubit.deleteContent(content.id),
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
                  context.read<ContentListCubit>().loadContents(),
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      );
}
