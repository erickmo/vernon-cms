import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../domain_builder/domain/entities/domain_definition.dart';
import '../../../domain_builder/domain/usecases/get_domains_usecase.dart';
import '../../domain/entities/domain_record.dart';
import '../cubit/domain_record_list_cubit.dart';
import '../widgets/dynamic_record_table.dart';
import '../../../content/presentation/widgets/delete_confirmation_dialog.dart';

/// Halaman daftar record domain.
class DomainRecordListPage extends StatelessWidget {
  /// Slug domain yang akan ditampilkan.
  final String slug;

  const DomainRecordListPage({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DomainRecordListCubit>(),
      child: _DomainRecordListView(slug: slug),
    );
  }
}

class _DomainRecordListView extends StatefulWidget {
  final String slug;

  const _DomainRecordListView({required this.slug});

  @override
  State<_DomainRecordListView> createState() => _DomainRecordListViewState();
}

class _DomainRecordListViewState extends State<_DomainRecordListView> {
  final _searchController = TextEditingController();
  DomainDefinition? _domain;

  @override
  void initState() {
    super.initState();
    _loadDomain();
  }

  @override
  void didUpdateWidget(_DomainRecordListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slug != widget.slug) {
      _loadDomain();
    }
  }

  Future<void> _loadDomain() async {
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
          context.read<DomainRecordListCubit>().loadRecords(
                domainSlug: widget.slug,
                domain: domain,
              );
        }
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_domain == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return BlocConsumer<DomainRecordListCubit, DomainRecordListState>(
      listener: _onStateChanged,
      builder: (context, state) => state.when(
        initial: () => const SizedBox.shrink(),
        loading: () => const Center(child: CircularProgressIndicator()),
        loaded: (domain, records, searchQuery) =>
            _buildContent(context, domain, records, searchQuery),
        error: (message) => _buildError(context, message),
      ),
    );
  }

  void _onStateChanged(BuildContext context, DomainRecordListState state) {
    state.whenOrNull(
      error: (message) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    DomainDefinition domain,
    List<DomainRecord> records,
    String searchQuery,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, domain),
          const SizedBox(height: AppDimensions.spacingL),
          _buildSearchBar(context, domain),
          const SizedBox(height: AppDimensions.spacingM),
          DynamicRecordTable(
            domain: domain,
            records: records,
            onEdit: (record) => context.go(
              '/domain/${widget.slug}/${record.id}/edit',
            ),
            onDelete: (record) => _showDeleteDialog(context, record),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DomainDefinition domain) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          domain.pluralName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => context.go('/domain/${widget.slug}/create'),
          icon: const Icon(Icons.add),
          label: Text('${AppStrings.domainRecordAdd} ${domain.name}'),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, DomainDefinition domain) {
    return SizedBox(
      width: 360,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '${AppStrings.domainRecordSearch} ${domain.pluralName.toLowerCase()}...',
          prefixIcon: const Icon(Icons.search),
          border: const OutlineInputBorder(),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<DomainRecordListCubit>().loadRecords(
                          domainSlug: widget.slug,
                          domain: domain,
                        );
                  },
                )
              : null,
        ),
        onSubmitted: (value) {
          context.read<DomainRecordListCubit>().loadRecords(
                domainSlug: widget.slug,
                domain: domain,
                search: value.isNotEmpty ? value : null,
              );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, DomainRecord record) {
    final cubit = context.read<DomainRecordListCubit>();
    DeleteConfirmationDialog.show(
      context: context,
      title: AppStrings.domainRecordDelete,
      message: AppStrings.domainRecordDeleteConfirm,
      onConfirm: () => cubit.deleteRecord(
        domainSlug: widget.slug,
        id: record.id,
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: AppDimensions.avatarL,
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              message,
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            ElevatedButton(
              onPressed: () {
                if (_domain != null) {
                  context.read<DomainRecordListCubit>().loadRecords(
                        domainSlug: widget.slug,
                        domain: _domain!,
                      );
                }
              },
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      );
}
