import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../content/presentation/widgets/delete_confirmation_dialog.dart';
import '../../domain/entities/page_entity.dart';
import '../cubit/page_list_cubit.dart';
import '../widgets/page_table.dart';

/// Halaman daftar halaman CMS.
class PageListPage extends StatelessWidget {
  const PageListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PageListCubit>()..loadPages(),
      child: const _PageListView(),
    );
  }
}

class _PageListView extends StatefulWidget {
  const _PageListView();

  @override
  State<_PageListView> createState() => _PageListViewState();
}

class _PageListViewState extends State<_PageListView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PageListCubit, PageListState>(
      listener: _onStateChanged,
      builder: (context, state) => state.when(
        initial: () => const SizedBox.shrink(),
        loading: () => const Center(child: CircularProgressIndicator()),
        loaded: (pages, searchQuery) => _buildContent(context, pages, searchQuery),
        error: (message) => _buildError(context, message),
      ),
    );
  }

  void _onStateChanged(BuildContext context, PageListState state) {
    state.whenOrNull(
      error: (message) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<PageEntity> pages,
    String searchQuery,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: AppDimensions.spacingL),
          _buildSearchBar(context),
          const SizedBox(height: AppDimensions.spacingM),
          PageTable(
            pages: pages,
            onEdit: (page) => context.go('/pages/${page.id}/edit'),
            onDelete: (page) => _showDeleteDialog(context, page),
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
          AppStrings.pageListTitle,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => context.go('/pages/create'),
          icon: const Icon(Icons.add),
          label: const Text(AppStrings.addPage),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return SizedBox(
      width: 360,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: AppStrings.searchPage,
          prefixIcon: const Icon(Icons.search),
          border: const OutlineInputBorder(),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<PageListCubit>().loadPages();
                  },
                )
              : null,
        ),
        onSubmitted: (value) {
          context
              .read<PageListCubit>()
              .loadPages(search: value.isNotEmpty ? value : null);
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, PageEntity page) {
    final cubit = context.read<PageListCubit>();
    DeleteConfirmationDialog.show(
      context: context,
      title: AppStrings.deletePage,
      message: '${AppStrings.deletePageConfirm} "${page.name}"?',
      onConfirm: () => cubit.deletePage(page.id),
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
                  context.read<PageListCubit>().loadPages(),
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      );
}
