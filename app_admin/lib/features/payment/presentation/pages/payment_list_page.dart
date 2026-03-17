import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/payment.dart';
import '../cubit/payment_list_cubit.dart';
import '../widgets/payment_status_badge.dart';

class PaymentListPage extends StatelessWidget {
  const PaymentListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PaymentListCubit>()..loadPayments(),
      child: const _PaymentListView(),
    );
  }
}

class _PaymentListView extends StatefulWidget {
  const _PaymentListView();

  @override
  State<_PaymentListView> createState() => _PaymentListViewState();
}

class _PaymentListViewState extends State<_PaymentListView> {
  PaymentStatus? _statusFilter;

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
          AppStrings.payments,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        ElevatedButton.icon(
          onPressed: () => context.push('/payments/create'),
          icon: const Icon(Icons.add, size: AppDimensions.iconM),
          label: const Text(AppStrings.paymentCreate),
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context) {
    final statuses = [
      (null, AppStrings.filterAll),
      (PaymentStatus.pending, AppStrings.filterPending),
      (PaymentStatus.paid, AppStrings.filterPaid),
      (PaymentStatus.failed, AppStrings.filterFailed),
      (PaymentStatus.cancelled, AppStrings.filterCancelled),
    ];
    return Wrap(
      spacing: AppDimensions.spacingS,
      children: statuses.map((item) {
        final isSelected = _statusFilter == item.$1;
        return ChoiceChip(
          label: Text(item.$2),
          selected: isSelected,
          onSelected: (_) {
            setState(() => _statusFilter = item.$1);
            context
                .read<PaymentListCubit>()
                .loadPayments(status: item.$1);
          },
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContent() {
    return BlocConsumer<PaymentListCubit, PaymentListState>(
      listener: (context, state) {
        if (state is PaymentListError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is PaymentListLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is PaymentListError) {
          return _buildEmpty(
            icon: Icons.error_outline,
            message: state.message,
            action: () =>
                context.read<PaymentListCubit>().loadPayments(),
            actionLabel: AppStrings.retry,
          );
        }
        if (state is PaymentListLoaded) {
          if (state.payments.isEmpty) {
            return _buildEmpty(
              icon: Icons.receipt_long_outlined,
              message: AppStrings.emptyData,
            );
          }
          return _buildTable(context, state.payments);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTable(BuildContext context, List<Payment> payments) {
    return Card(
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.background),
          dataRowMinHeight: AppDimensions.tableRowHeight,
          dataRowMaxHeight: AppDimensions.tableRowHeight,
          columns: const [
            DataColumn(label: Text('Client')),
            DataColumn(label: Text('Jumlah')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Metode')),
            DataColumn(label: Text('Jatuh Tempo')),
            DataColumn(label: Text('Tanggal Bayar')),
            DataColumn(label: Text('Aksi')),
          ],
          rows: payments.map((payment) {
            return DataRow(cells: [
              DataCell(
                Text(
                  payment.clientName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () => context.push('/payments/${payment.id}'),
              ),
              DataCell(
                Text(
                  DateFormatter.formatCurrency(payment.amount),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              DataCell(PaymentStatusBadge(status: payment.status)),
              DataCell(Text(payment.method ?? '-')),
              DataCell(Text(DateFormatter.format(payment.dueDate))),
              DataCell(Text(DateFormatter.format(payment.paidAt))),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.visibility_outlined,
                      size: AppDimensions.iconM),
                  onPressed: () =>
                      context.push('/payments/${payment.id}'),
                  tooltip: AppStrings.detail,
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
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
}
