import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/media_file.dart';

/// Card tunggal untuk menampilkan file media dalam grid.
/// Menampilkan thumbnail, file type badge, nama file, dan ukuran.
/// Saat hover menampilkan overlay dengan tombol "Lihat Detail".
class MediaCard extends StatefulWidget {
  /// File media yang ditampilkan.
  final MediaFile file;

  /// Callback saat card ditekan.
  final VoidCallback onTap;

  const MediaCard({
    super.key,
    required this.file,
    required this.onTap,
  });

  @override
  State<MediaCard> createState() => _MediaCardState();
}

class _MediaCardState extends State<MediaCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: _isHovered ? 4 : 1,
      shadowColor: _isHovered
          ? AppColors.primary.withValues(alpha: 0.2)
          : Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        side: BorderSide(
          color: _isHovered ? AppColors.primary.withValues(alpha: 0.3) : AppColors.divider,
        ),
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildThumbnail(),
                    _buildTypeBadge(),
                    if (_isHovered) _buildHoverOverlay(),
                  ],
                ),
              ),
              _buildInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    if (_isImage) {
      final url = widget.file.thumbnailUrl ?? widget.file.fileUrl;
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, error, stackTrace) => _buildIconPlaceholder(),
      );
    }
    return _buildIconPlaceholder();
  }

  Widget _buildIconPlaceholder() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Icon(
          _mimeTypeIcon,
          size: AppDimensions.avatarL,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildTypeBadge() {
    return Positioned(
      top: AppDimensions.spacingS,
      left: AppDimensions.spacingS,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingS,
          vertical: AppDimensions.spacingXS,
        ),
        decoration: BoxDecoration(
          color: _badgeColor.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
        child: Text(
          _fileTypeLabel,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildHoverOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
      ),
      child: Center(
        child: ElevatedButton.icon(
          onPressed: widget.onTap,
          icon: const Icon(Icons.visibility, size: 16),
          label: const Text(
            AppStrings.mediaViewDetail,
            style: TextStyle(fontSize: 12),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textPrimary,
            elevation: 2,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingM,
              vertical: AppDimensions.spacingS,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.file.fileName,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.spacingXS),
          Row(
            children: [
              Text(
                _formatFileSize(widget.file.fileSize),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(widget.file.createdAt),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool get _isImage => widget.file.mimeType.startsWith('image/');

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

  String get _fileTypeLabel {
    if (widget.file.mimeType.startsWith('image/')) return 'IMAGE';
    if (widget.file.mimeType == 'application/pdf') return 'PDF';
    if (widget.file.mimeType.startsWith('video/')) return 'VIDEO';
    if (widget.file.mimeType.contains('word') ||
        widget.file.mimeType.contains('document')) {
      return 'DOC';
    }
    if (widget.file.mimeType.startsWith('text/')) return 'TEXT';
    return 'FILE';
  }

  Color get _badgeColor {
    if (widget.file.mimeType.startsWith('image/')) return AppColors.primary;
    if (widget.file.mimeType == 'application/pdf') return AppColors.error;
    if (widget.file.mimeType.startsWith('video/')) return AppColors.warning;
    return AppColors.textSecondary;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
