import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../cubit/payment_form_cubit.dart';

class PaymentFormPage extends StatelessWidget {
  const PaymentFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PaymentFormCubit>()..loadClients(),
      child: const _PaymentFormView(),
    );
  }
}

class _PaymentFormView extends StatefulWidget {
  const _PaymentFormView();

  @override
  State<_PaymentFormView> createState() => _PaymentFormViewState();
}

class _PaymentFormViewState extends State<_PaymentFormView> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _methodCtrl = TextEditingController();
  String? _selectedClientId;
  DateTime? _dueDate;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    _methodCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<PaymentFormCubit, PaymentFormState>(
        listener: (context, state) {
          if (state is PaymentFormSuccess) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
            context.go('/payments');
          }
          if (state is PaymentFormError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ));
          }
        },
        builder: (context, state) {
          if (state is PaymentFormLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: AppDimensions.spacingL),
                Expanded(
                  child: Card(
                    child: SingleChildScrollView(
                      padding:
                          const EdgeInsets.all(AppDimensions.spacingXL),
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(maxWidth: 600),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                            children: [
                              _buildClientDropdown(context, state),
                              const SizedBox(
                                  height: AppDimensions.spacingM),
                              TextFormField(
                                controller: _amountCtrl,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                decoration: const InputDecoration(
                                  labelText: AppStrings.paymentAmount,
                                  prefixText: 'Rp ',
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Jumlah wajib diisi';
                                  }
                                  if (double.tryParse(v) == null) {
                                    return 'Format angka tidak valid';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                  height: AppDimensions.spacingM),
                              TextFormField(
                                controller: _methodCtrl,
                                decoration: const InputDecoration(
                                  labelText: AppStrings.paymentMethod,
                                  hintText: 'Transfer, Tunai, dll',
                                ),
                              ),
                              const SizedBox(
                                  height: AppDimensions.spacingM),
                              _buildDatePicker(context),
                              const SizedBox(
                                  height: AppDimensions.spacingM),
                              TextFormField(
                                controller: _descCtrl,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  labelText: AppStrings.paymentDescription,
                                ),
                              ),
                              const SizedBox(
                                  height: AppDimensions.spacingXL),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    onPressed: () =>
                                        context.go('/payments'),
                                    child: const Text(AppStrings.cancel),
                                  ),
                                  const SizedBox(
                                      width: AppDimensions.spacingM),
                                  BlocBuilder<PaymentFormCubit,
                                      PaymentFormState>(
                                    builder: (context, state) {
                                      final isSaving =
                                          state is PaymentFormSaving;
                                      return ElevatedButton(
                                        onPressed:
                                            isSaving ? null : _submit,
                                        child: isSaving
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : const Text(AppStrings.save),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
          AppStrings.paymentCreate,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
      ],
    );
  }

  Widget _buildClientDropdown(
      BuildContext context, PaymentFormState state) {
    final clients =
        state is PaymentFormReady ? state.clients : <dynamic>[];
    return DropdownButtonFormField<String>(
      value: _selectedClientId,
      decoration: const InputDecoration(
          labelText: AppStrings.paymentClient),
      items: clients.map<DropdownMenuItem<String>>((c) {
        return DropdownMenuItem(
          value: c.id as String,
          child: Text(c.name as String),
        );
      }).toList(),
      onChanged: (v) => setState(() => _selectedClientId = v),
      validator: (v) =>
          v == null ? 'Client wajib dipilih' : null,
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now().add(const Duration(days: 30)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) setState(() => _dueDate = picked);
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: AppStrings.paymentDueDate,
          suffixIcon: Icon(Icons.calendar_today_outlined),
        ),
        child: Text(
          _dueDate != null
              ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
              : 'Pilih tanggal',
          style: TextStyle(
            color: _dueDate != null
                ? AppColors.textPrimary
                : AppColors.textHint,
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<PaymentFormCubit>().submit(
          clientId: _selectedClientId!,
          amount: double.parse(_amountCtrl.text),
          description: _descCtrl.text.trim(),
          method: _methodCtrl.text.trim(),
          dueDate: _dueDate,
        );
  }
}
