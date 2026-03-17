import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';

/// Tab konten form: title, slug, excerpt, dan body WYSIWYG editor.
class ContentFormMain extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController slugController;
  final TextEditingController excerptController;
  final QuillController quillController;
  final VoidCallback onSlugManualEdit;

  const ContentFormMain({
    super.key,
    required this.titleController,
    required this.slugController,
    required this.excerptController,
    required this.quillController,
    required this.onSlugManualEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTitleField(),
        const SizedBox(height: AppDimensions.spacingM),
        _buildSlugField(),
        const SizedBox(height: AppDimensions.spacingM),
        _buildExcerptField(),
        const SizedBox(height: AppDimensions.spacingM),
        _buildBodyEditor(context),
      ],
    );
  }

  Widget _buildTitleField() => TextFormField(
        controller: titleController,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        decoration: const InputDecoration(
          hintText: AppStrings.contentTitleHint,
          hintStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: AppColors.textHint,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: AppDimensions.spacingS,
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return AppStrings.contentTitleRequired;
          }
          return null;
        },
      );

  Widget _buildSlugField() => Row(
        children: [
          const Text(
            'slug: ',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textHint,
              fontFamily: 'monospace',
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: slugController,
              onChanged: (_) => onSlugManualEdit(),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontFamily: 'monospace',
              ),
              decoration: const InputDecoration(
                hintText: 'your-post-slug',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.contentSlugRequired;
                }
                return null;
              },
            ),
          ),
        ],
      );

  Widget _buildExcerptField() => TextFormField(
        controller: excerptController,
        maxLines: 2,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
          fontStyle: FontStyle.italic,
        ),
        decoration: const InputDecoration(
          hintText: AppStrings.contentExcerptHint,
          hintStyle: TextStyle(
            fontSize: 13,
            color: AppColors.textHint,
            fontStyle: FontStyle.italic,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: AppDimensions.spacingXS),
        ),
      );

  Widget _buildBodyEditor(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildEditorToolbar(context),
          const Divider(color: AppColors.divider, height: 1),
          Container(
            constraints: const BoxConstraints(minHeight: 400),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingS,
              vertical: AppDimensions.spacingM,
            ),
            child: Localizations.override(
              context: context,
              locale: const Locale('en', ''),
              child: QuillEditor.basic(
                controller: quillController,
                config: QuillEditorConfig(
                  placeholder: AppStrings.contentBodyHint,
                  padding: EdgeInsets.zero,
                  autoFocus: false,
                  expands: false,
                  scrollable: false,
                  customStyles: DefaultStyles(
                    paragraph: DefaultTextBlockStyle(
                      const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.7,
                      ),
                      const HorizontalSpacing(0, 0),
                      const VerticalSpacing(2, 2),
                      const VerticalSpacing(0, 0),
                      null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );

  Widget _buildEditorToolbar(BuildContext context) => Localizations.override(
        context: context,
        locale: const Locale('en', ''),
        child: QuillSimpleToolbar(
          controller: quillController,
          config: const QuillSimpleToolbarConfig(
            showFontFamily: false,
            showFontSize: false,
            showSubscript: false,
            showSuperscript: false,
            showColorButton: false,
            showBackgroundColorButton: false,
            showInlineCode: true,
            showListCheck: false,
            showCodeBlock: false,
            showAlignmentButtons: false,
            showIndent: false,
            showRedo: true,
            showUndo: true,
            showDividers: true,
            showClearFormat: true,
            showSearchButton: false,
            showClipboardPaste: false,
            showClipboardCopy: false,
            showClipboardCut: false,
            toolbarSize: 40,
            toolbarIconAlignment: WrapAlignment.start,
            toolbarSectionSpacing: 4,
          ),
        ),
      );
}
