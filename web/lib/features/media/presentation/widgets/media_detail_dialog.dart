import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/media_file.dart';

/// Dialog untuk menampilkan detail media, edit metadata, copy URL, hapus.
class MediaDetailDialog extends StatefulWidget {
  /// File media yang ditampilkan.
  final MediaFile file;

  /// Callback saat metadata diperbarui.
  final void Function(String? alt, String? caption, String? folder) onUpdate;

  /// Callback saat file dihapus.
  final VoidCallback onDelete;

  const MediaDetailDialog({
    super.key,
    required this.file,
    required this.onUpdate,
    required this.onDelete,
  });

  /// Menampilkan dialog detail media.
  static Future<void> show({
    required BuildContext context,
    required MediaFile file,
    required void Function(String? alt, String? caption, String? folder)
        onUpdate,
    required VoidCallback onDelete,
  }) {
    return showDialog(
      context: context,
      builder: (_) => MediaDetailDialog(
        file: file,
        onUpdate: onUpdate,
        onDelete: onDelete,
      ),
    );
  }

  @override
  State<MediaDetailDialog> createState() => _MediaDetailDialogState();
}

class _MediaDetailDialogState extends State<MediaDetailDialog> {
  late final TextEditingController _altController;
  late final TextEditingController _captionController;
  late final TextEditingController _folderController;

  @override
  void initState() {
    super.initState();
    _altController = TextEditingController(text: widget.file.alt ?? '');
    _captionController = TextEditingController(text: widget.file.caption ?? '');
    _folderController = TextEditingController(text: widget.file.folder ?? '');
  }

  @override
  void dispose() {
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
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              const SizedBox(height: AppDimensions.spacingM),
              Flexible(
                child: SingleChildScrollView(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildPreview()),
                      const SizedBox(width: AppDimensions.spacingL),
                      Expanded(child: _buildMetadataForm()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingM),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.file.fileName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    if (widget.file.mimeType.startsWith('image/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Image.network(
          widget.file.fileUrl,
          fit: BoxFit.contain,
          errorBuilder: (_, error, stackTrace) => _buildFilePlaceholder(),
        ),
      );
    }
    return _buildFilePlaceholder();
  }

  Widget _buildFilePlaceholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Center(
        child: Icon(
          _mimeTypeIcon,
          size: AppDimensions.avatarL,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildMetadataForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildInfoRow(AppStrings.mediaFileSize, _formatFileSize(widget.file.fileSize)),
        if (widget.file.width != null && widget.file.height != null)
          _buildInfoRow(
            AppStrings.mediaDimensions,
            '${widget.file.width} x ${widget.file.height}',
          ),
        _buildInfoRow(AppStrings.mediaMimeType, widget.file.mimeType),
        const SizedBox(height: AppDimensions.spacingM),
        _buildUrlCopyField(),
        const SizedBox(height: AppDimensions.spacingM),
        TextField(
          controller: _altController,
          decoration: const InputDecoration(
            labelText: AppStrings.mediaAltText,
            hintText: AppStrings.mediaAltTextHint,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        TextField(
          controller: _captionController,
          decoration: const InputDecoration(
            labelText: AppStrings.mediaCaption,
            hintText: AppStrings.mediaCaptionHint,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        TextField(
          controller: _folderController,
          decoration: const InputDecoration(
            labelText: AppStrings.mediaFolder,
            hintText: AppStrings.mediaFolderHint,
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingXS),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlCopyField() {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.file.fileUrl,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, size: AppDimensions.iconS),
          tooltip: AppStrings.mediaCopyUrl,
          onPressed: () {
            Clipboard.setData(ClipboardData(text: widget.file.fileUrl));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(AppStrings.mediaUrlCopied)),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: () {
            widget.onDelete();
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.delete, color: AppColors.error),
          label: const Text(
            AppStrings.delete,
            style: TextStyle(color: AppColors.error),
          ),
        ),
        Row(
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(AppStrings.cancel),
            ),
            const SizedBox(width: AppDimensions.spacingS),
            ElevatedButton(
              onPressed: () {
                widget.onUpdate(
                  _altController.text.isNotEmpty ? _altController.text : null,
                  _captionController.text.isNotEmpty
                      ? _captionController.text
                      : null,
                  _folderController.text.isNotEmpty
                      ? _folderController.text
                      : null,
                );
                Navigator.of(context).pop();
              },
              child: const Text(AppStrings.save),
            ),
          ],
        ),
      ],
    );
  }

  IconData get _mimeTypeIcon {
    if (widget.file.mimeType.startsWith('image/')) return Icons.photo;
    if (widget.file.mimeType == 'application/pdf') return Icons.picture_as_pdf;
    if (widget.file.mimeType.startsWith('video/')) return Icons.videocam;
    if (widget.file.mimeType.contains('word') ||
        widget.file.mimeType.contains('document') ||
        widget.file.mimeType.contains('text/')) {
      return Icons.description;
    }
    return Icons.insert_drive_file;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
