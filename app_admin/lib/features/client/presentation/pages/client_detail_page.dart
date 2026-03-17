import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/date_formatter.dart';
import '../cubit/client_detail_cubit.dart';
import '../widgets/client_status_badge.dart';

class ClientDetailPage extends StatelessWidget {
  final String clientId;
  const ClientDetailPage({super.key, required this.clientId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ClientDetailCubit>()..loadClient(clientId),
      child: _ClientDetailView(clientId: clientId),
    );
  }
}

class _ClientDetailView extends StatelessWidget {
  final String clientId;
  const _ClientDetailView({required this.clientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<ClientDetailCubit, ClientDetailState>(
        listener: (context, state) {
          if (state is ClientDetailError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, state),
                const SizedBox(height: AppDimensions.spacingL),
                if (state is ClientDetailLoading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state is ClientDetailLoaded)
                  Expanded(child: _buildDetail(context, state)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ClientDetailState state) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/clients'),
        ),
        const SizedBox(width: AppDimensions.spacingS),
        Text(
          AppStrings.clientDetail,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const Spacer(),
        if (state is ClientDetailLoaded) ...[
          OutlinedButton.icon(
            onPressed: () => context.push('/clients/${state.client.id}/edit'),
            icon: const Icon(Icons.edit_outlined, size: AppDimensions.iconM),
            label: const Text(AppStrings.edit),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          ElevatedButton.icon(
            onPressed: () => _confirmToggle(context, state),
            icon: Icon(
              state.client.isActive ? Icons.toggle_off : Icons.toggle_on,
              size: AppDimensions.iconM,
            ),
            label: Text(state.client.isActive
                ? AppStrings.clientToggleInactive
                : AppStrings.clientToggleActive),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  state.client.isActive ? AppColors.warning : AppColors.success,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDetail(BuildContext context, ClientDetailLoaded state) {
    final client = state.client;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    client.name.isNotEmpty
                        ? client.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingM),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.name,
                      style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXS),
                    ClientStatusBadge(isActive: client.isActive),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingXL),
            const Divider(),
            const SizedBox(height: AppDimensions.spacingL),
            _buildInfoGrid(client),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoGrid(client) {
    final items = [
      ('Email', client.email, Icons.email_outlined),
      ('Telepon', client.phone ?? '-', Icons.phone_outlined),
      ('Perusahaan', client.company ?? '-', Icons.business_outlined),
      ('Alamat', client.address ?? '-', Icons.location_on_outlined),
      ('Dibuat', DateFormatter.formatWithTime(client.createdAt), Icons.calendar_today_outlined),
      ('Diperbarui', DateFormatter.formatWithTime(client.updatedAt), Icons.update_outlined),
    ];
    return Wrap(
      spacing: AppDimensions.spacingXL,
      runSpacing: AppDimensions.spacingL,
      children: items.map((item) {
        return SizedBox(
          width: 280,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(item.$3,
                  size: AppDimensions.iconM, color: AppColors.textSecondary),
              const SizedBox(width: AppDimensions.spacingS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.$1,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        )),
                    const SizedBox(height: 2),
                    Text(item.$2,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        )),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _confirmToggle(BuildContext context, ClientDetailLoaded state) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.confirm),
        content: Text(state.client.isActive
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
              await context
                  .read<ClientDetailCubit>()
                  .toggleActive(state.client.id);
              if (context.mounted) {
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
}
