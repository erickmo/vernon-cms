import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/date_formatter.dart';
import '../cubit/payment_detail_cubit.dart';
import '../widgets/payment_status_badge.dart';

class PaymentDetailPage extends StatelessWidget {
  final String paymentId;
  const PaymentDetailPage({super.key, required this.paymentId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<PaymentDetailCubit>()..loadPayment(paymentId),
      child: const _PaymentDetailView(),
    );
  }
}

class _PaymentDetailView extends StatelessWidget {
  const _PaymentDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<PaymentDetailCubit, PaymentDetailState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: AppDimensions.spacingL),
                if (state is PaymentDetailLoading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state is PaymentDetailLoaded)
                  Expanded(child: _buildDetail(context, state)),
                else if (state is PaymentDetailError)
                  Expanded(
                    child: Center(
                      child: Text(state.message,
                          style: const TextStyle(color: AppColors.error)),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/payments'),
        ),
        const SizedBox(width: AppDimensions.spacingS),
        Text(
          AppStrings.paymentDetail,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
      ],
    );
  }

  Widget _buildDetail(BuildContext context, PaymentDetailLoaded state) {
    final p = state.payment;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormatter.formatCurrency(p.amount),
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: AppDimensions.spacingS),
                      PaymentStatusBadge(status: p.status),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingXL),
            const Divider(),
            const SizedBox(height: AppDimensions.spacingL),
            Wrap(
              spacing: AppDimensions.spacingXL,
              runSpacing: AppDimensions.spacingL,
              children: [
                _infoItem('Client', p.clientName, Icons.person_outline),
                _infoItem('Keterangan', p.description ?? '-',
                    Icons.notes_outlined),
                _infoItem(
                    'Metode', p.method ?? '-', Icons.payment_outlined),
                _infoItem('Jatuh Tempo',
                    DateFormatter.format(p.dueDate), Icons.calendar_today_outlined),
                _infoItem('Tanggal Bayar',
                    DateFormatter.format(p.paidAt), Icons.check_circle_outline),
                _infoItem('Dibuat',
                    DateFormatter.formatWithTime(p.createdAt), Icons.access_time_outlined),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(String label, String value, IconData icon) {
    return SizedBox(
      width: 260,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppDimensions.iconM, color: AppColors.textSecondary),
          const SizedBox(width: AppDimensions.spacingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
