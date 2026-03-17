import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/content.dart';
import '../../domain/entities/content_category.dart';
import '../../../page_management/domain/entities/page_entity.dart';
import '../../../page_management/domain/usecases/get_pages_usecase.dart';
import '../cubit/content_category_cubit.dart';
import '../cubit/content_form_cubit.dart';
import '../widgets/content_form_main.dart';
import '../widgets/content_seo_tab.dart';
import '../widgets/content_settings_tab.dart';

/// Halaman form konten — tabs: Konten | SEO | Pengaturan.
class ContentFormPage extends StatelessWidget {
  final String? contentId;

  const ContentFormPage({super.key, this.contentId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final cubit = getIt<ContentFormCubit>();
            if (contentId != null) cubit.loadContent(contentId!);
            return cubit;
          },
        ),
        BlocProvider(
          create: (_) => getIt<ContentCategoryCubit>()..loadCategories(),
        ),
      ],
      child: _ContentFormView(contentId: contentId),
    );
  }
}

class _ContentFormView extends StatefulWidget {
  final String? contentId;
  const _ContentFormView({this.contentId});

  @override
  State<_ContentFormView> createState() => _ContentFormViewState();
}

class _ContentFormViewState extends State<_ContentFormView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Main
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _slugController;
  late final TextEditingController _excerptController;
  late QuillController _quillController;

  // SEO
  late final TextEditingController _seoTitleController;
  late final TextEditingController _seoDescriptionController;
  late final TextEditingController _seoKeywordsController;
  late final TextEditingController _ogTitleController;
  late final TextEditingController _ogDescriptionController;
  late final TextEditingController _ogImageController;
  late final TextEditingController _canonicalUrlController;
  String _robots = 'index,follow';

  // Settings
  String _status = 'draft';
  String? _pageId;
  String? _categoryId;
  bool _autoSlug = true;
  bool _initialized = false;
  List<PageEntity> _pages = [];

  bool get _isEditing => widget.contentId != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _quillController = QuillController.basic();
    _titleController = TextEditingController();
    _slugController = TextEditingController();
    _excerptController = TextEditingController();
    _seoTitleController = TextEditingController();
    _seoDescriptionController = TextEditingController();
    _seoKeywordsController = TextEditingController();
    _ogTitleController = TextEditingController();
    _ogDescriptionController = TextEditingController();
    _ogImageController = TextEditingController();
    _canonicalUrlController = TextEditingController();

    _titleController.addListener(_onTitleChanged);
    if (!_isEditing) _initialized = true;
    _loadPages();
  }

  Future<void> _loadPages() async {
    try {
      final result = await getIt<GetPagesUseCase>()();
      result.fold((_) {}, (pages) {
        if (mounted) setState(() => _pages = pages);
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _tabController.dispose();
    _quillController.dispose();
    _titleController.dispose();
    _slugController.dispose();
    _excerptController.dispose();
    _seoTitleController.dispose();
    _seoDescriptionController.dispose();
    _seoKeywordsController.dispose();
    _ogTitleController.dispose();
    _ogDescriptionController.dispose();
    _ogImageController.dispose();
    _canonicalUrlController.dispose();
    super.dispose();
  }

  void _onTitleChanged() {
    if (_autoSlug) {
      _slugController.text = _generateSlug(_titleController.text);
    }
  }

  String _generateSlug(String name) => name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
      .replaceAll(RegExp(r'\s+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');

  void _populateFields(Content content) {
    _titleController.text = content.title;
    _slugController.text = content.slug;
    _excerptController.text = content.excerpt ?? '';

    // Load body into Quill
    final body = content.body ?? '';
    if (body.isNotEmpty) {
      try {
        if (body.trimLeft().startsWith('[')) {
          final deltaJson = jsonDecode(body) as List;
          _quillController.dispose();
          _quillController = QuillController(
            document: Document.fromJson(deltaJson),
            selection: const TextSelection.collapsed(offset: 0),
          );
        } else {
          // Plain text / HTML — insert as plain text
          _quillController.document.insert(0, body);
        }
      } catch (_) {
        try {
          _quillController.document.insert(0, body);
        } catch (_) {}
      }
    }

    // Load SEO from metadata
    final meta = content.metadata;
    _seoTitleController.text = (meta['seo_title'] as String?) ?? '';
    _seoDescriptionController.text = (meta['seo_description'] as String?) ?? '';
    _seoKeywordsController.text = (meta['seo_keywords'] as String?) ?? '';
    _ogTitleController.text = (meta['og_title'] as String?) ?? '';
    _ogDescriptionController.text = (meta['og_description'] as String?) ?? '';
    _ogImageController.text = (meta['og_image'] as String?) ?? '';
    _canonicalUrlController.text = (meta['canonical_url'] as String?) ?? '';
    _robots = (meta['robots'] as String?) ?? 'index,follow';

    _status = content.status;
    _pageId = content.pageId;
    _categoryId = content.categoryId;
    _autoSlug = false;
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      // Go to content tab if validation fails
      _tabController.animateTo(0);
      return;
    }

    // Serialize Quill body as Delta JSON
    final bodyDelta = _quillController.document.toDelta().toJson();
    final bodyJson = jsonEncode(bodyDelta);
    final isBodyEmpty = _quillController.document.isEmpty();

    final metadata = {
      'seo_title': _seoTitleController.text.trim(),
      'seo_description': _seoDescriptionController.text.trim(),
      'seo_keywords': _seoKeywordsController.text.trim(),
      'og_title': _ogTitleController.text.trim(),
      'og_description': _ogDescriptionController.text.trim(),
      'og_image': _ogImageController.text.trim(),
      'canonical_url': _canonicalUrlController.text.trim(),
      'robots': _robots,
    };

    final cubit = context.read<ContentFormCubit>();
    final existing = cubit.state is ContentFormLoaded
        ? (cubit.state as ContentFormLoaded).content
        : null;

    final now = DateTime.now();
    final content = Content(
      id: existing?.id ?? '',
      title: _titleController.text.trim(),
      slug: _slugController.text.trim(),
      body: isBodyEmpty ? null : bodyJson,
      excerpt: _excerptController.text.trim().isEmpty
          ? null
          : _excerptController.text.trim(),
      status: _status,
      pageId: _pageId,
      categoryId: _categoryId,
      authorId: existing?.authorId,
      metadata: metadata,
      publishedAt: existing?.publishedAt,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    final success = _isEditing
        ? await cubit.updateContent(content)
        : await cubit.createContent(content);

    if (success && mounted) context.go('/content');
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContentFormCubit, ContentFormState>(
      listener: _onFormStateChanged,
      builder: (context, state) {
        if (state is ContentFormLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!_initialized && state is ContentFormLoaded) {
          _initialized = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _populateFields(state.content));
          });
        }
        return _buildPage(context, isSaving: state is ContentFormSaving);
      },
    );
  }

  void _onFormStateChanged(BuildContext context, ContentFormState state) {
    state.whenOrNull(
      error: (message) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.error),
      ),
      saved: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? AppStrings.contentUpdated : AppStrings.contentCreated,
          ),
          backgroundColor: AppColors.success,
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, {required bool isSaving}) {
    final categories =
        context.watch<ContentCategoryCubit>().state is ContentCategoryLoaded
            ? (context.watch<ContentCategoryCubit>().state
                    as ContentCategoryLoaded)
                .categories
            : <ContentCategory>[];

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context, isSaving),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Konten
                SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.spacingL),
                  child: ContentFormMain(
                    titleController: _titleController,
                    slugController: _slugController,
                    excerptController: _excerptController,
                    quillController: _quillController,
                    onSlugManualEdit: () => _autoSlug = false,
                  ),
                ),
                // Tab 2: SEO
                ContentSeoTab(
                  seoTitleController: _seoTitleController,
                  seoDescriptionController: _seoDescriptionController,
                  seoKeywordsController: _seoKeywordsController,
                  ogTitleController: _ogTitleController,
                  ogDescriptionController: _ogDescriptionController,
                  ogImageController: _ogImageController,
                  canonicalUrlController: _canonicalUrlController,
                  robots: _robots,
                  onRobotsChanged: (v) => setState(() => _robots = v),
                  contentTitle: _titleController.text,
                  contentSlug: _slugController.text,
                ),
                // Tab 3: Pengaturan
                ContentSettingsTab(
                  status: _status,
                  onStatusChanged: (v) =>
                      setState(() => _status = v ?? 'draft'),
                  pageId: _pageId,
                  onPageChanged: (v) => setState(() => _pageId = v),
                  pages: _pages,
                  categoryId: _categoryId,
                  onCategoryChanged: (v) => setState(() => _categoryId = v),
                  categories: categories,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isSaving) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingL,
          vertical: AppDimensions.spacingS,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              onPressed: () => context.go('/content'),
              tooltip: AppStrings.back,
              style: IconButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingS),
            Text(
              _isEditing ? AppStrings.editContent : AppStrings.addContent,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: isSaving ? null : () => context.go('/content'),
              child: const Text(AppStrings.cancel),
            ),
            const SizedBox(width: AppDimensions.spacingS),
            FilledButton.icon(
              onPressed: isSaving ? null : _onSave,
              icon: isSaving
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_rounded, size: 16),
              label: Text(isSaving ? 'Menyimpan...' : AppStrings.save),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildTabBar() => Container(
        color: AppColors.surface,
        child: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(icon: Icon(Icons.edit_note_rounded, size: 16), text: 'Konten'),
            Tab(icon: Icon(Icons.manage_search_rounded, size: 16), text: 'SEO'),
            Tab(icon: Icon(Icons.tune_rounded, size: 16), text: 'Pengaturan'),
          ],
        ),
      );
}
