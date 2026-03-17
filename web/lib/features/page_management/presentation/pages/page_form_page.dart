import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/page_entity.dart';
import '../cubit/page_form_cubit.dart';
import '../widgets/page_form_main.dart';
import '../widgets/page_form_sidebar.dart';

/// Halaman form untuk membuat atau mengedit halaman CMS.
class PageFormPage extends StatelessWidget {
  /// ID halaman yang akan diedit. Null jika membuat baru.
  final String? pageId;

  const PageFormPage({super.key, this.pageId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<PageFormCubit>();
        if (pageId != null) {
          cubit.loadPage(pageId!);
        }
        return cubit;
      },
      child: _PageFormView(pageId: pageId),
    );
  }
}

class _PageFormView extends StatefulWidget {
  final String? pageId;

  const _PageFormView({this.pageId});

  @override
  State<_PageFormView> createState() => _PageFormViewState();
}

class _PageFormViewState extends State<_PageFormView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _slugController;

  Map<String, dynamic> _variables = {};
  bool _isActive = true;
  bool _autoSlug = true;
  bool _initialized = false;

  bool get _isEditing => widget.pageId != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _slugController = TextEditingController();

    _nameController.addListener(_onNameChanged);

    if (!_isEditing) {
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    if (_autoSlug) {
      _slugController.text = _generateSlug(_nameController.text);
    }
  }

  String _generateSlug(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  void _populateFields(PageEntity page) {
    _nameController.text = page.name;
    _slugController.text = page.slug;

    setState(() {
      _variables = Map<String, dynamic>.from(page.variables);
      _isActive = page.isActive;
      _autoSlug = false;
      _initialized = true;
    });
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<PageFormCubit>();
    final now = DateTime.now();

    // Dapatkan halaman lama dari state jika sedang edit.
    PageEntity? existingPage;
    final currentState = cubit.state;
    if (currentState is PageFormLoaded) {
      existingPage = currentState.page;
    }

    final pageEntity = PageEntity(
      id: existingPage?.id ?? '',
      name: _nameController.text.trim(),
      slug: _slugController.text.trim(),
      variables: _variables,
      isActive: _isActive,
      createdAt: existingPage?.createdAt ?? now,
      updatedAt: now,
    );

    if (_isEditing) {
      cubit.updatePage(pageEntity);
    } else {
      cubit.createPage(pageEntity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PageFormCubit, PageFormState>(
      listener: _onStateChanged,
      builder: (context, state) {
        return state.when(
          initial: () => _buildForm(context, isSaving: false),
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: (page) {
            if (!_initialized) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _populateFields(page);
              });
            }
            return _buildForm(context, isSaving: false);
          },
          saving: () => _buildForm(context, isSaving: true),
          saved: () => _buildForm(context, isSaving: false),
          error: (message) => _buildForm(context, isSaving: false),
        );
      },
    );
  }

  void _onStateChanged(BuildContext context, PageFormState state) {
    state.whenOrNull(
      saved: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? AppStrings.pageUpdated
                  : AppStrings.pageCreated,
            ),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/pages');
      },
      error: (message) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, {required bool isSaving}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormHeader(context, isSaving: isSaving),
            const SizedBox(height: AppDimensions.spacingL),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 900) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildMainPanel(),
                      ),
                      const SizedBox(width: AppDimensions.spacingL),
                      Expanded(
                        flex: 2,
                        child: _buildSidebarPanel(),
                      ),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildMainPanel(),
                    const SizedBox(height: AppDimensions.spacingL),
                    _buildSidebarPanel(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormHeader(BuildContext context, {required bool isSaving}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => context.go('/pages'),
              icon: const Icon(Icons.arrow_back),
              tooltip: AppStrings.back,
            ),
            const SizedBox(width: AppDimensions.spacingS),
            Text(
              _isEditing ? AppStrings.editPage : AppStrings.addPage,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        Row(
          children: [
            TextButton(
              onPressed: isSaving ? null : () => context.go('/pages'),
              child: const Text(AppStrings.cancel),
            ),
            const SizedBox(width: AppDimensions.spacingS),
            ElevatedButton(
              onPressed: isSaving ? null : _onSave,
              child: isSaving
                  ? const SizedBox(
                      width: AppDimensions.iconS,
                      height: AppDimensions.iconS,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(AppStrings.save),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainPanel() {
    return PageFormMain(
      nameController: _nameController,
      slugController: _slugController,
      variables: _variables,
      onVariablesChanged: (v) => setState(() => _variables = v),
      onSlugManualEdit: () => _autoSlug = false,
    );
  }

  Widget _buildSidebarPanel() {
    return PageFormSidebar(
      isActive: _isActive,
      onIsActiveChanged: (value) => setState(() => _isActive = value),
    );
  }
}
