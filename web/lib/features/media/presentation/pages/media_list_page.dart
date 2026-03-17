import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../content/presentation/widgets/delete_confirmation_dialog.dart';
import '../../domain/entities/media_file.dart';
import '../cubit/media_list_cubit.dart';
import '../widgets/media_detail_dialog.dart';
import '../widgets/media_grid.dart';
import '../widgets/media_upload_dialog.dart';

/// Halaman daftar media.
class MediaListPage extends StatelessWidget {
  const MediaListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MediaListCubit>()..loadMedia(),
      child: const _MediaListView(),
    );
  }
}

class _MediaListView extends StatefulWidget {
  const _MediaListView();

  @override
  State<_MediaListView> createState() => _MediaListViewState();
}

class _MediaListViewState extends State<_MediaListView> {
  final _searchController = TextEditingController();
  String? _selectedMimeType;
  String? _selectedFolder;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MediaListCubit, MediaListState>(
      listener: _onStateChanged,
      builder: (context, state) => state.when(
        initial: () => const SizedBox.shrink(),
        loading: () => const Center(child: CircularProgressIndicator()),
        loaded: (files, folders, searchQuery, mimeTypeFilter, folderFilter) =>
            _buildContent(context, files, folders),
        error: (message) => _buildError(context, message),
      ),
    );
  }

  void _onStateChanged(BuildContext context, MediaListState state) {
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
    List<MediaFile> files,
    List<String> folders,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: AppDimensions.spacingL),
          _buildFilterCard(context, folders),
          const SizedBox(height: AppDimensions.spacingM),
          _buildStatsRow(files),
          const SizedBox(height: AppDimensions.spacingM),
          if (files.isEmpty)
            _buildEmptyState()
          else
            MediaGrid(
              files: files,
              onTap: (file) => _showDetailDialog(context, file),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.mediaTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXS),
            const Text(
              AppStrings.mediaDescription,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        FilledButton.icon(
          onPressed: () => _showUploadDialog(context),
          icon: const Icon(Icons.cloud_upload_outlined, size: AppDimensions.iconM),
          label: const Text(AppStrings.mediaUpload),
        ),
      ],
    );
  }

  Widget _buildFilterCard(BuildContext context, List<String> folders) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;
            if (isWide) {
              return Row(
                children: [
                  Expanded(flex: 3, child: _buildSearchField(context)),
                  const SizedBox(width: AppDimensions.spacingM),
                  Expanded(child: _buildMimeTypeDropdown(context)),
                  if (folders.isNotEmpty) ...[
                    const SizedBox(width: AppDimensions.spacingM),
                    Expanded(child: _buildFolderDropdown(context, folders)),
                  ],
                ],
              );
            }
            return Wrap(
              spacing: AppDimensions.spacingM,
              runSpacing: AppDimensions.spacingS,
              children: [
                SizedBox(width: double.infinity, child: _buildSearchField(context)),
                SizedBox(width: 180, child: _buildMimeTypeDropdown(context)),
                if (folders.isNotEmpty)
                  SizedBox(width: 180, child: _buildFolderDropdown(context, folders)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: AppStrings.mediaSearch,
        hintStyle: const TextStyle(color: AppColors.textHint),
        prefixIcon: const Icon(Icons.search, size: AppDimensions.iconM),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingM,
          vertical: AppDimensions.spacingS,
        ),
        isDense: true,
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: AppDimensions.iconM),
                onPressed: () {
                  _searchController.clear();
                  _applyFilters(context);
                },
              )
            : null,
      ),
      onSubmitted: (_) => _applyFilters(context),
    );
  }

  Widget _buildMimeTypeDropdown(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: _selectedMimeType,
      decoration: InputDecoration(
        labelText: AppStrings.mediaTypeFilter,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingM,
          vertical: AppDimensions.spacingS,
        ),
        isDense: true,
      ),
      items: const [
        DropdownMenuItem(value: null, child: Text(AppStrings.mediaAllTypes)),
        DropdownMenuItem(value: 'image', child: Text(AppStrings.mediaImages)),
        DropdownMenuItem(
            value: 'application/pdf', child: Text(AppStrings.mediaDocuments)),
        DropdownMenuItem(value: 'video', child: Text(AppStrings.mediaVideos)),
      ],
      onChanged: (value) {
        setState(() => _selectedMimeType = value);
        _applyFilters(context);
      },
    );
  }

  Widget _buildFolderDropdown(BuildContext context, List<String> folders) {
    return DropdownButtonFormField<String>(
      value: _selectedFolder,
      decoration: InputDecoration(
        labelText: AppStrings.mediaFolder,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingM,
          vertical: AppDimensions.spacingS,
        ),
        isDense: true,
      ),
      items: [
        const DropdownMenuItem(
            value: null, child: Text(AppStrings.mediaAllFolders)),
        ...folders.map(
          (f) => DropdownMenuItem(value: f, child: Text(f)),
        ),
      ],
      onChanged: (value) {
        setState(() => _selectedFolder = value);
        _applyFilters(context);
      },
    );
  }

  Widget _buildStatsRow(List<MediaFile> files) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingM,
            vertical: AppDimensions.spacingXS,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
          ),
          child: Text(
            '${files.length} file',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingXXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.perm_media_outlined,
                size: AppDimensions.avatarL,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            const Text(
              'Belum ada media',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            const Text(
              'Upload file pertama Anda untuk memulai',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyFilters(BuildContext context) {
    context.read<MediaListCubit>().loadMedia(
          search: _searchController.text.isNotEmpty
              ? _searchController.text
              : null,
          mimeType: _selectedMimeType,
          folder: _selectedFolder,
        );
  }

  void _showUploadDialog(BuildContext context) {
    final cubit = context.read<MediaListCubit>();
    MediaUploadDialog.show(
      context: context,
      onUpload: (data) async {
        final success = await cubit.uploadMedia(data);
        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.mediaUploaded)),
          );
        }
      },
    );
  }

  void _showDetailDialog(BuildContext context, MediaFile file) {
    final cubit = context.read<MediaListCubit>();
    MediaDetailDialog.show(
      context: context,
      file: file,
      onUpdate: (alt, caption, folder) async {
        final data = <String, dynamic>{};
        if (alt != null) data['alt'] = alt;
        if (caption != null) data['caption'] = caption;
        if (folder != null) data['folder'] = folder;
        final success = await cubit.updateMedia(file.id, data);
        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.mediaUpdated)),
          );
        }
      },
      onDelete: () => _showDeleteDialog(context, file),
    );
  }

  void _showDeleteDialog(BuildContext context, MediaFile file) {
    final cubit = context.read<MediaListCubit>();
    DeleteConfirmationDialog.show(
      context: context,
      title: AppStrings.mediaDelete,
      message: '${AppStrings.mediaDeleteConfirm} "${file.fileName}"?',
      onConfirm: () async {
        final success = await cubit.deleteMedia(file.id);
        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.mediaDeleted)),
          );
        }
      },
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
              onPressed: () => context.read<MediaListCubit>().loadMedia(),
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      );
}
