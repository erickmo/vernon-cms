import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/media_file.dart';
import '../cubit/media_list_cubit.dart';
import 'media_card.dart';

/// Dialog pemilih media yang dapat digunakan ulang dari form lain.
/// Mengembalikan URL file yang dipilih.
class MediaPickerDialog extends StatelessWidget {
  const MediaPickerDialog({super.key});

  /// Menampilkan dialog pemilih media dan mengembalikan URL file yang dipilih.
  static Future<String?> show({required BuildContext context}) {
    return showDialog<String>(
      context: context,
      builder: (_) => BlocProvider(
        create: (_) => getIt<MediaListCubit>()..loadMedia(),
        child: const MediaPickerDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              const SizedBox(height: AppDimensions.spacingM),
              _buildSearchBar(context),
              const SizedBox(height: AppDimensions.spacingM),
              Expanded(child: _buildContent(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.perm_media, color: AppColors.primary),
        const SizedBox(width: AppDimensions.spacingS),
        const Expanded(
          child: Text(
            AppStrings.mediaPickerTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        hintText: AppStrings.mediaSearch,
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
      onSubmitted: (value) {
        context.read<MediaListCubit>().loadMedia(
              search: value.isNotEmpty ? value : null,
            );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    return BlocBuilder<MediaListCubit, MediaListState>(
      builder: (context, state) => state.when(
        initial: () => const SizedBox.shrink(),
        loading: () => const Center(child: CircularProgressIndicator()),
        loaded: (files, folders, searchQuery, mimeTypeFilter, folderFilter) =>
            _buildGrid(context, files),
        error: (message) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: AppDimensions.avatarL,
                color: AppColors.error,
              ),
              const SizedBox(height: AppDimensions.spacingS),
              Text(message),
              const SizedBox(height: AppDimensions.spacingS),
              ElevatedButton(
                onPressed: () =>
                    context.read<MediaListCubit>().loadMedia(),
                child: const Text(AppStrings.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<MediaFile> files) {
    if (files.isEmpty) {
      return const Center(child: Text(AppStrings.emptyData));
    }
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppDimensions.spacingS,
        mainAxisSpacing: AppDimensions.spacingS,
        childAspectRatio: 0.85,
      ),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        return MediaCard(
          file: file,
          onTap: () => Navigator.of(context).pop(file.fileUrl),
        );
      },
    );
  }
}
