import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/date_formatter.dart';
import '../cubit/client_list_cubit.dart';
import '../widgets/client_status_badge.dart';

class ClientListPage extends StatelessWidget {
  const ClientListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ClientListCubit>()..loadClients(),
      child: const _ClientListView(),
    );
  }
}

class _ClientListView extends StatefulWidget {
  const _ClientListView();

  @override
  State<_ClientListView> createState() => _ClientListViewState();
}

class _ClientListViewState extends State<_ClientListView> {
  final _searchCtrl = TextEditingController();
  bool? _activeFilter;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: AppDimensions.spacingL),
            _buildFilters(context),
            const SizedBox(height: AppDimensions.spacingM),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppStrings.clients,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        ElevatedButton.icon(
          onPressed: () => context.push('/clients/create'),
          icon: const Icon(Icons.add, size: AppDimensions.iconM),
          label: const Text(AppStrings.clientCreate),
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchCtrl,
            decoration: const InputDecoration(
              hintText: AppStrings.search,
              prefixIcon: Icon(Icons.search, size: AppDimensions.iconM),
            ),
            onSubmitted: (_) => _applyFilters(context),
          ),
        ),
        const SizedBox(width: AppDimensions.spacingM),
        DropdownButtonHideUnderline(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingM,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: DropdownButton<bool?>(
              value: _activeFilter,
              items: const [
                DropdownMenuItem(value: null, child: Text('Semua Status')),
                DropdownMenuItem(value: true, child: Text(AppStrings.active)),
                DropdownMenuItem(
                    value: false, child: Text(AppStrings.inactive)),
              ],
              onChanged: (v) {
                setState(() => _activeFilter = v);
                _applyFilters(context);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return BlocConsumer<ClientListCubit, ClientListState>(
      listener: (context, state) {
        if (state is ClientListError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ClientListLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ClientListError) {
          return _buildEmpty(
            icon: Icons.error_outline,
            message: state.message,
            action: () => context.read<ClientListCubit>().loadClients(),
            actionLabel: AppStrings.retry,
          );
        }
        if (state is ClientListLoaded) {
          if (state.clients.isEmpty) {
            return _buildEmpty(
              icon: Icons.people_outline,
              message: _searchCtrl.text.isNotEmpty
                  ? AppStrings.emptySearch
                  : AppStrings.emptyData,
            );
          }
          return _buildTable(context, state);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTable(BuildContext context, ClientListLoaded state) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.background),
                dataRowMinHeight: AppDimensions.tableRowHeight,
                dataRowMaxHeight: AppDimensions.tableRowHeight,
                columns: const [
                  DataColumn(label: Text('Nama')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Perusahaan')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Dibuat')),
                  DataColumn(label: Text('Aksi')),
                ],
                rows: state.clients.map((client) {
                  return DataRow(cells: [
                    DataCell(
                      Text(
                        client.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      onTap: () => context.push('/clients/${client.id}'),
                    ),
                    DataCell(Text(client.email)),
                    DataCell(Text(client.company ?? '-')),
                    DataCell(ClientStatusBadge(isActive: client.isActive)),
                    DataCell(Text(DateFormatter.format(client.createdAt))),
                    DataCell(_buildActions(context, client.id, client.isActive)),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(
      BuildContext context, String id, bool isActive) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.visibility_outlined,
              size: AppDimensions.iconM),
          onPressed: () => context.push('/clients/$id'),
          tooltip: AppStrings.detail,
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: AppDimensions.iconM),
          onPressed: () => context.push('/clients/$id/edit'),
          tooltip: AppStrings.edit,
        ),
        IconButton(
          icon: Icon(
            isActive ? Icons.toggle_on : Icons.toggle_off,
            color: isActive ? AppColors.success : AppColors.textHint,
            size: AppDimensions.iconM,
          ),
          onPressed: () => _confirmToggle(context, id, isActive),
          tooltip: isActive
              ? AppStrings.clientToggleInactive
              : AppStrings.clientToggleActive,
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline,
              size: AppDimensions.iconM, color: AppColors.error),
          onPressed: () => _confirmDelete(context, id),
          tooltip: AppStrings.delete,
        ),
      ],
    );
  }

  Widget _buildEmpty({
    required IconData icon,
    required String message,
    VoidCallback? action,
    String? actionLabel,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textHint),
          const SizedBox(height: AppDimensions.spacingM),
          Text(message,
              style: const TextStyle(color: AppColors.textSecondary)),
          if (action != null) ...[
            const SizedBox(height: AppDimensions.spacingM),
            OutlinedButton(
                onPressed: action, child: Text(actionLabel ?? '')),
          ],
        ],
      ),
    );
  }

  void _applyFilters(BuildContext context) {
    context.read<ClientListCubit>().loadClients(
          search: _searchCtrl.text.trim().isNotEmpty
              ? _searchCtrl.text.trim()
              : null,
          isActive: _activeFilter,
        );
  }

  void _confirmToggle(BuildContext context, String id, bool isActive) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.confirm),
        content: Text(isActive
            ? AppStrings.clientToggleInactive
            : AppStrings.clientToggleActive),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final ok =
                  await context.read<ClientListCubit>().toggleActive(id);
              if (ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(AppStrings.clientToggled)),
                );
              }
            },
            child: const Text(AppStrings.confirm),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.delete),
        content: const Text(AppStrings.clientDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(context);
              final ok =
                  await context.read<ClientListCubit>().deleteClient(id);
              if (ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(AppStrings.clientDeleted)),
                );
              }
            },
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }
}
