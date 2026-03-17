import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/domain_definition.dart';
import '../../domain/entities/domain_field_definition.dart';
import '../cubit/domain_builder_cubit.dart';
import '../cubit/domain_form_cubit.dart';
import '../widgets/field_definition_list.dart';

/// Halaman form domain builder (create/edit).
class DomainBuilderFormPage extends StatelessWidget {
  /// ID domain yang akan diedit. Null jika membuat baru.
  final String? domainId;

  const DomainBuilderFormPage({super.key, this.domainId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final cubit = getIt<DomainFormCubit>();
            if (domainId != null) {
              cubit.loadDomain(domainId!);
            }
            return cubit;
          },
        ),
        BlocProvider(
          create: (_) => getIt<DomainBuilderCubit>()..loadDomains(),
        ),
      ],
      child: _DomainBuilderFormView(domainId: domainId),
    );
  }
}

class _DomainBuilderFormView extends StatefulWidget {
  final String? domainId;

  const _DomainBuilderFormView({this.domainId});

  @override
  State<_DomainBuilderFormView> createState() =>
      _DomainBuilderFormViewState();
}

class _DomainBuilderFormViewState extends State<_DomainBuilderFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _slugController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _iconController;
  late final TextEditingController _pluralNameController;
  late final TextEditingController _sidebarOrderController;

  String _sidebarSection = 'content';
  List<DomainFieldDefinition> _fields = [];
  bool _autoSlug = true;
  bool _isInitialized = false;

  bool get _isEditing => widget.domainId != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _slugController = TextEditingController();
    _descriptionController = TextEditingController();
    _iconController = TextEditingController();
    _pluralNameController = TextEditingController();
    _sidebarOrderController = TextEditingController(text: '0');

    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _descriptionController.dispose();
    _iconController.dispose();
    _pluralNameController.dispose();
    _sidebarOrderController.dispose();
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

  void _populateForm(DomainDefinition domain) {
    if (_isInitialized) return;
    _isInitialized = true;

    _nameController.text = domain.name;
    _slugController.text = domain.slug;
    _descriptionController.text = domain.description ?? '';
    _iconController.text = domain.icon ?? '';
    _pluralNameController.text = domain.pluralName;
    _sidebarSection = domain.sidebarSection;
    _sidebarOrderController.text = '${domain.sidebarOrder}';
    _fields = List.from(domain.fields);
    _autoSlug = false;
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final domain = DomainDefinition(
      id: widget.domainId ?? '',
      name: _nameController.text.trim(),
      slug: _slugController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      icon: _iconController.text.trim().isEmpty
          ? null
          : _iconController.text.trim(),
      pluralName: _pluralNameController.text.trim().isEmpty
          ? _nameController.text.trim()
          : _pluralNameController.text.trim(),
      sidebarSection: _sidebarSection,
      sidebarOrder: int.tryParse(_sidebarOrderController.text) ?? 0,
      fields: _fields,
      createdAt: now,
      updatedAt: now,
    );

    final cubit = context.read<DomainFormCubit>();
    if (_isEditing) {
      cubit.updateDomain(domain);
    } else {
      cubit.createDomain(domain);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DomainFormCubit, DomainFormState>(
      listener: _onFormStateChanged,
      builder: (context, state) {
        return state.when(
          initial: () => _buildForm(context),
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: (domain) {
            _populateForm(domain);
            return _buildForm(context);
          },
          saving: () => _buildForm(context, isSaving: true),
          saved: (_) => _buildForm(context),
          error: (message) => _buildForm(context, errorMessage: message),
        );
      },
    );
  }

  void _onFormStateChanged(BuildContext context, DomainFormState state) {
    state.whenOrNull(
      saved: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? AppStrings.domainUpdated
                  : AppStrings.domainCreated,
            ),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/domain-builder');
      },
      error: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.error,
          ),
        );
      },
    );
  }

  Widget _buildForm(
    BuildContext context, {
    bool isSaving = false,
    String? errorMessage,
  }) {
    final availableDomains =
        context.watch<DomainBuilderCubit>().state.whenOrNull(
              loaded: (domains) => domains,
            ) ??
            <DomainDefinition>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, isSaving),
            const SizedBox(height: AppDimensions.spacingL),
            _buildBasicInfoSection(),
            const SizedBox(height: AppDimensions.spacingL),
            _buildSidebarConfigSection(),
            const SizedBox(height: AppDimensions.spacingL),
            FieldDefinitionList(
              fields: _fields,
              availableDomains: availableDomains,
              onChanged: (fields) {
                setState(() {
                  _fields = fields;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isSaving) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => context.go('/domain-builder'),
              icon: const Icon(Icons.arrow_back),
            ),
            const SizedBox(width: AppDimensions.spacingS),
            Text(
              _isEditing
                  ? AppStrings.domainEdit
                  : AppStrings.domainAdd,
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
              onPressed: () => context.go('/domain-builder'),
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

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.domainBasicInfo,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.domainName,
                      hintText: AppStrings.domainNameHint,
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppStrings.domainNameRequired;
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingM),
                Expanded(
                  child: TextFormField(
                    controller: _slugController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.domainSlug,
                      hintText: AppStrings.domainSlugHint,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) {
                      _autoSlug = false;
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppStrings.domainSlugRequired;
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _pluralNameController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.domainPluralName,
                      hintText: AppStrings.domainPluralNameHint,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingM),
                Expanded(
                  child: TextFormField(
                    controller: _iconController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.domainIcon,
                      hintText: AppStrings.domainIconHint,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingM),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: AppStrings.domainDescription,
                hintText: AppStrings.domainDescriptionHint,
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarConfigSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.domainSidebarConfig,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _sidebarSection,
                    decoration: const InputDecoration(
                      labelText: AppStrings.domainSidebarSection,
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'content',
                        child: Text('Content'),
                      ),
                      DropdownMenuItem(
                        value: 'pages',
                        child: Text('Pages'),
                      ),
                      DropdownMenuItem(
                        value: 'master_data',
                        child: Text('Master Data'),
                      ),
                      DropdownMenuItem(
                        value: 'custom',
                        child: Text('Custom'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _sidebarSection = value ?? 'content';
                      });
                    },
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingM),
                Expanded(
                  child: TextFormField(
                    controller: _sidebarOrderController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.domainSidebarOrder,
                      hintText: '0',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
