import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../domain_builder/domain/entities/domain_definition.dart';
import '../../../domain_builder/domain/entities/domain_field_definition.dart';
import '../../../domain_builder/domain/entities/field_type.dart';
import '../../../domain_builder/domain/usecases/get_domains_usecase.dart';
import '../../domain/entities/domain_record.dart';
import '../../domain/entities/record_option.dart';
import '../../domain/usecases/get_record_options_usecase.dart';
import '../cubit/domain_record_form_cubit.dart';
import '../widgets/dynamic_field_widget.dart';

/// Halaman form record domain untuk membuat atau mengedit record.
class DomainRecordFormPage extends StatelessWidget {
  /// Slug domain.
  final String slug;

  /// ID record yang akan diedit. Null jika membuat baru.
  final String? recordId;

  const DomainRecordFormPage({
    super.key,
    required this.slug,
    this.recordId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<DomainRecordFormCubit>();
        if (recordId != null) {
          cubit.loadRecord(domainSlug: slug, id: recordId!);
        }
        return cubit;
      },
      child: _DomainRecordFormView(slug: slug, recordId: recordId),
    );
  }
}

class _DomainRecordFormView extends StatefulWidget {
  final String slug;
  final String? recordId;

  const _DomainRecordFormView({
    required this.slug,
    this.recordId,
  });

  @override
  State<_DomainRecordFormView> createState() => _DomainRecordFormViewState();
}

class _DomainRecordFormViewState extends State<_DomainRecordFormView> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  final Map<String, List<RecordOption>> _relationOptions = {};

  DomainDefinition? _domain;
  bool _initialized = false;

  bool get _isEditing => widget.recordId != null;

  @override
  void initState() {
    super.initState();
    _loadDomainAndOptions();

    // Jika create, langsung set initialized.
    if (!_isEditing) {
      _initialized = true;
    }
  }

  Future<void> _loadDomainAndOptions() async {
    final getDomainsUseCase = getIt<GetDomainsUseCase>();
    final result = await getDomainsUseCase();
    result.fold(
      (_) {},
      (domains) {
        final domain = domains
            .where((d) => d.slug == widget.slug)
            .firstOrNull;
        if (domain != null && mounted) {
          setState(() => _domain = domain);
          _loadRelationOptions(domain);

          // Set default values untuk create mode.
          if (!_isEditing) {
            for (final field in domain.fields) {
              if (field.defaultValue != null) {
                _formData[field.name] = field.defaultValue;
              }
            }
          }
        }
      },
    );
  }

  Future<void> _loadRelationOptions(DomainDefinition domain) async {
    final getRecordOptionsUseCase = getIt<GetRecordOptionsUseCase>();
    final relationFields = domain.fields
        .where((f) => f.fieldType == FieldType.relation && f.relatedDomainSlug != null);

    for (final field in relationFields) {
      final result = await getRecordOptionsUseCase(
        domainSlug: field.relatedDomainSlug!,
      );
      result.fold(
        (_) {},
        (options) {
          if (mounted) {
            setState(() {
              _relationOptions[field.name] = options;
            });
          }
        },
      );
    }
  }

  void _populateFields(DomainRecord record) {
    _formData.addAll(record.data);
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<DomainRecordFormCubit>();

    final bool success;
    if (_isEditing) {
      success = await cubit.updateRecord(
        domainSlug: widget.slug,
        id: widget.recordId!,
        data: Map<String, dynamic>.from(_formData),
      );
    } else {
      success = await cubit.createRecord(
        domainSlug: widget.slug,
        data: Map<String, dynamic>.from(_formData),
      );
    }

    if (success && mounted) {
      context.go('/domain/${widget.slug}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_domain == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return BlocConsumer<DomainRecordFormCubit, DomainRecordFormState>(
      listener: _onFormStateChanged,
      builder: (context, state) {
        return state.when(
          initial: () => _buildForm(context),
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: (record) {
            if (!_initialized) {
              _initialized = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _populateFields(record);
                  });
                }
              });
            }
            return _buildForm(context);
          },
          saving: () => _buildForm(context, isSaving: true),
          saved: (_) => _buildForm(context),
          error: (message) => _buildForm(context),
        );
      },
    );
  }

  void _onFormStateChanged(BuildContext context, DomainRecordFormState state) {
    state.whenOrNull(
      error: (message) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
        ),
      ),
      saved: (_) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? AppStrings.domainRecordUpdated
                : AppStrings.domainRecordCreated,
          ),
          backgroundColor: AppColors.success,
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, {bool isSaving = false}) {
    final domain = _domain!;
    final sortedFields = List<DomainFieldDefinition>.from(domain.fields)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, domain, isSaving),
            const SizedBox(height: AppDimensions.spacingL),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: sortedFields
                      .map((field) => DynamicFieldWidget(
                            field: field,
                            value: _formData[field.name],
                            relationOptions:
                                _relationOptions[field.name] ?? const [],
                            onChanged: (value) {
                              setState(() {
                                _formData[field.name] = value;
                              });
                            },
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    DomainDefinition domain,
    bool isSaving,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => context.go('/domain/${widget.slug}'),
              icon: const Icon(Icons.arrow_back),
              tooltip: AppStrings.back,
            ),
            const SizedBox(width: AppDimensions.spacingS),
            Text(
              _isEditing
                  ? '${AppStrings.domainRecordEdit} ${domain.name}'
                  : '${AppStrings.domainRecordAdd} ${domain.name}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
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
    );
  }
}
