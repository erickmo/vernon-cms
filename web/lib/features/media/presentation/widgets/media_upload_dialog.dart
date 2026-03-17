import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';

/// Dialog untuk mengunggah media baru via URL.
class MediaUploadDialog extends StatefulWidget {
  /// Callback saat upload dikonfirmasi.
  final void Function(Map<String, dynamic> data) onUpload;

  const MediaUploadDialog({
    super.key,
    required this.onUpload,
  });

  /// Menampilkan dialog upload media.
  static Future<void> show({
    required BuildContext context,
    required void Function(Map<String, dynamic> data) onUpload,
  }) {
    return showDialog(
      context: context,
      builder: (_) => MediaUploadDialog(onUpload: onUpload),
    );
  }

  @override
  State<MediaUploadDialog> createState() => _MediaUploadDialogState();
}

class _MediaUploadDialogState extends State<MediaUploadDialog> {
  final _formKey = GlobalKey<FormState>();
  final _fileUrlController = TextEditingController();
  final _fileNameController = TextEditingController();
  final _altController = TextEditingController();
  final _captionController = TextEditingController();
  final _folderController = TextEditingController();

  @override
  void dispose() {
    _fileUrlController.dispose();
    _fileNameController.dispose();
    _altController.dispose();
    _captionController.dispose();
    _folderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingL),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                const SizedBox(height: AppDimensions.spacingL),
                _buildDivider(),
                const SizedBox(height: AppDimensions.spacingL),
                _buildFields(),
                const SizedBox(height: AppDimensions.spacingL),
                _buildActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          child: const Icon(
            Icons.cloud_upload_outlined,
            color: AppColors.primary,
            size: AppDimensions.iconM,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingM),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.mediaUpload,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Tambahkan file media via URL',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
          style: IconButton.styleFrom(foregroundColor: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return const Divider(color: AppColors.divider, height: 1);
  }

  Widget _buildFields() {
    return Column(
      children: [
        TextFormField(
          controller: _fileUrlController,
          decoration: const InputDecoration(
            labelText: AppStrings.mediaFileUrl,
            hintText: AppStrings.mediaFileUrlHint,
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.link),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppStrings.mediaFileUrlRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: AppDimensions.spacingM),
        TextFormField(
          controller: _fileNameController,
          decoration: const InputDecoration(
            labelText: AppStrings.mediaFileName,
            hintText: AppStrings.mediaFileNameHint,
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.insert_drive_file_outlined),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppStrings.mediaFileNameRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: AppDimensions.spacingM),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _altController,
                decoration: const InputDecoration(
                  labelText: AppStrings.mediaAltText,
                  hintText: AppStrings.mediaAltTextHint,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingM),
            Expanded(
              child: TextFormField(
                controller: _folderController,
                decoration: const InputDecoration(
                  labelText: AppStrings.mediaFolder,
                  hintText: AppStrings.mediaFolderHint,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingM),
        TextFormField(
          controller: _captionController,
          decoration: const InputDecoration(
            labelText: AppStrings.mediaCaption,
            hintText: AppStrings.mediaCaptionHint,
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancel),
        ),
        const SizedBox(width: AppDimensions.spacingS),
        FilledButton.icon(
          onPressed: _onSubmit,
          icon: const Icon(Icons.cloud_upload_outlined, size: AppDimensions.iconM),
          label: const Text(AppStrings.mediaUpload),
        ),
      ],
    );
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final data = <String, dynamic>{
      'file_url': _fileUrlController.text,
      'file_name': _fileNameController.text,
    };

    if (_altController.text.isNotEmpty) {
      data['alt'] = _altController.text;
    }
    if (_captionController.text.isNotEmpty) {
      data['caption'] = _captionController.text;
    }
    if (_folderController.text.isNotEmpty) {
      data['folder'] = _folderController.text;
    }

    widget.onUpload(data);
    Navigator.of(context).pop();
  }
}
