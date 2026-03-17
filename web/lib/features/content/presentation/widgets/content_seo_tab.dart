import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Tab SEO form konten: seo title, meta description, keywords, OG fields.
class ContentSeoTab extends StatefulWidget {
  final TextEditingController seoTitleController;
  final TextEditingController seoDescriptionController;
  final TextEditingController seoKeywordsController;
  final TextEditingController ogTitleController;
  final TextEditingController ogDescriptionController;
  final TextEditingController ogImageController;
  final TextEditingController canonicalUrlController;
  final String robots;
  final ValueChanged<String> onRobotsChanged;
  final String contentTitle;
  final String contentSlug;

  const ContentSeoTab({
    super.key,
    required this.seoTitleController,
    required this.seoDescriptionController,
    required this.seoKeywordsController,
    required this.ogTitleController,
    required this.ogDescriptionController,
    required this.ogImageController,
    required this.canonicalUrlController,
    required this.robots,
    required this.onRobotsChanged,
    required this.contentTitle,
    required this.contentSlug,
  });

  @override
  State<ContentSeoTab> createState() => _ContentSeoTabState();
}

class _ContentSeoTabState extends State<ContentSeoTab> {
  @override
  void initState() {
    super.initState();
    widget.seoTitleController.addListener(_rebuild);
    widget.seoDescriptionController.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.seoTitleController.removeListener(_rebuild);
    widget.seoDescriptionController.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 800;
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildSeoFields()),
                const SizedBox(width: AppDimensions.spacingL),
                Expanded(flex: 2, child: _buildPreviewPanel()),
              ],
            );
          }
          return Column(
            children: [
              _buildPreviewPanel(),
              const SizedBox(height: AppDimensions.spacingL),
              _buildSeoFields(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSeoFields() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSection(
            title: 'SEO Dasar',
            icon: Icons.search_rounded,
            children: [
              _buildCharCountField(
                controller: widget.seoTitleController,
                label: 'SEO Title',
                hint: widget.contentTitle.isNotEmpty
                    ? widget.contentTitle
                    : 'Judul untuk mesin pencari',
                maxChars: 60,
              ),
              const SizedBox(height: AppDimensions.spacingM),
              _buildCharCountField(
                controller: widget.seoDescriptionController,
                label: 'Meta Description',
                hint: 'Deskripsi singkat halaman ini (maks 155 karakter)',
                maxChars: 155,
                maxLines: 3,
              ),
              const SizedBox(height: AppDimensions.spacingM),
              TextFormField(
                controller: widget.seoKeywordsController,
                decoration: const InputDecoration(
                  labelText: 'Meta Keywords',
                  hintText: 'keyword1, keyword2, keyword3',
                  prefixIcon: Icon(Icons.label_outline, size: 18),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingM),
              TextFormField(
                controller: widget.canonicalUrlController,
                decoration: const InputDecoration(
                  labelText: 'Canonical URL',
                  hintText: 'https://example.com/canonical-url',
                  prefixIcon: Icon(Icons.link_rounded, size: 18),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingM),
              DropdownButtonFormField<String>(
                value: widget.robots,
                decoration: const InputDecoration(
                  labelText: 'Robots',
                  prefixIcon: Icon(Icons.smart_toy_outlined, size: 18),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'index,follow',
                    child: Text('index, follow (default)'),
                  ),
                  DropdownMenuItem(
                    value: 'noindex,follow',
                    child: Text('noindex, follow'),
                  ),
                  DropdownMenuItem(
                    value: 'index,nofollow',
                    child: Text('index, nofollow'),
                  ),
                  DropdownMenuItem(
                    value: 'noindex,nofollow',
                    child: Text('noindex, nofollow'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) widget.onRobotsChanged(v);
                },
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),
          _buildSection(
            title: 'Open Graph (Social Media)',
            icon: Icons.share_rounded,
            children: [
              TextFormField(
                controller: widget.ogTitleController,
                decoration: const InputDecoration(
                  labelText: 'OG Title',
                  hintText: 'Judul saat dibagikan di media sosial',
                  prefixIcon: Icon(Icons.title_rounded, size: 18),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingM),
              TextFormField(
                controller: widget.ogDescriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'OG Description',
                  hintText: 'Deskripsi saat dibagikan di media sosial',
                  prefixIcon: Icon(Icons.description_outlined, size: 18),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingM),
              TextFormField(
                controller: widget.ogImageController,
                decoration: const InputDecoration(
                  labelText: 'OG Image URL',
                  hintText: 'https://example.com/image.jpg (1200x630px)',
                  prefixIcon: Icon(Icons.image_outlined, size: 18),
                ),
              ),
            ],
          ),
        ],
      );

  Widget _buildPreviewPanel() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildGooglePreview(),
          const SizedBox(height: AppDimensions.spacingM),
          _buildSeoScore(),
        ],
      );

  Widget _buildGooglePreview() {
    final displayTitle = widget.seoTitleController.text.isNotEmpty
        ? widget.seoTitleController.text
        : (widget.contentTitle.isNotEmpty ? widget.contentTitle : 'Judul Halaman');
    final displayDescription = widget.seoDescriptionController.text.isNotEmpty
        ? widget.seoDescriptionController.text
        : 'Deskripsi halaman akan tampil di sini. Tambahkan meta description yang menarik untuk meningkatkan click-through rate.';
    final displayUrl = widget.canonicalUrlController.text.isNotEmpty
        ? widget.canonicalUrlController.text
        : 'https://example.com/${widget.contentSlug.isNotEmpty ? widget.contentSlug : "post-slug"}';

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.search, size: 16, color: AppColors.textHint),
              const SizedBox(width: AppDimensions.spacingXS),
              const Text(
                'Google Preview',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textHint,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          // URL bar
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingS,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_outline, size: 12, color: AppColors.textHint),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    displayUrl,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          // Title
          Text(
            displayTitle.length > 60 ? '${displayTitle.substring(0, 60)}...' : displayTitle,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF1A0DAB),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          // URL
          Text(
            displayUrl,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF006621),
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Description
          Text(
            displayDescription.length > 160
                ? '${displayDescription.substring(0, 160)}...'
                : displayDescription,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF545454),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeoScore() {
    final titleLen = widget.seoTitleController.text.length;
    final descLen = widget.seoDescriptionController.text.length;
    int score = 0;
    if (titleLen >= 30 && titleLen <= 60) score += 30;
    if (descLen >= 100 && descLen <= 155) score += 30;
    if (widget.seoKeywordsController.text.isNotEmpty) score += 20;
    if (widget.ogImageController.text.isNotEmpty) score += 20;

    final color = score >= 70
        ? AppColors.success
        : score >= 40
            ? AppColors.warning
            : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircularProgressIndicator(
            value: score / 100,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeWidth: 4,
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SEO Score: $score/100',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  score >= 70
                      ? 'Bagus! SEO sudah teroptimasi.'
                      : score >= 40
                          ? 'Cukup. Tambahkan meta description & OG image.'
                          : 'Perlu perbaikan. Isi SEO title & description.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) =>
      Container(
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(color: AppColors.divider, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppColors.primary),
                const SizedBox(width: AppDimensions.spacingS),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingM),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: AppDimensions.spacingM),
            ...children,
          ],
        ),
      );

  Widget _buildCharCountField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required int maxChars,
    int maxLines = 1,
  }) {
    final len = controller.text.length;
    final isOver = len > maxChars;
    final isGood = len >= (maxChars * 0.5).round() && !isOver;
    final countColor = isOver
        ? AppColors.error
        : isGood
            ? AppColors.success
            : AppColors.textHint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            suffixText: '${len}/$maxChars',
            suffixStyle: TextStyle(
              fontSize: 11,
              color: countColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (isOver)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              '$label melebihi $maxChars karakter',
              style: const TextStyle(fontSize: 11, color: AppColors.error),
            ),
          ),
      ],
    );
  }
}
