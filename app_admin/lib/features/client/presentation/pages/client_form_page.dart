import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../cubit/client_form_cubit.dart';

class ClientFormPage extends StatelessWidget {
  final String? clientId;
  const ClientFormPage({super.key, this.clientId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<ClientFormCubit>();
        if (clientId != null) {
          cubit.loadClient(clientId!);
        } else {
          cubit.initCreate();
        }
        return cubit;
      },
      child: _ClientFormView(clientId: clientId),
    );
  }
}

class _ClientFormView extends StatefulWidget {
  final String? clientId;
  const _ClientFormView({this.clientId});

  @override
  State<_ClientFormView> createState() => _ClientFormViewState();
}

class _ClientFormViewState extends State<_ClientFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  bool _populated = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _companyCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.clientId != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<ClientFormCubit, ClientFormState>(
        listener: (context, state) {
          if (state is ClientFormReady && !_populated) {
            if (state.existingClient != null) {
              final c = state.existingClient!;
              _nameCtrl.text = c.name;
              _emailCtrl.text = c.email;
              _phoneCtrl.text = c.phone ?? '';
              _companyCtrl.text = c.company ?? '';
              _addressCtrl.text = c.address ?? '';
              _populated = true;
            }
          }
          if (state is ClientFormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.go('/clients');
          }
          if (state is ClientFormError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ClientFormLoadingData) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, isEdit),
                const SizedBox(height: AppDimensions.spacingL),
                Expanded(
                  child: Card(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppDimensions.spacingXL),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildField(
                                controller: _nameCtrl,
                                label: AppStrings.clientName,
                                required: true,
                              ),
                              const SizedBox(height: AppDimensions.spacingM),
                              _buildField(
                                controller: _emailCtrl,
                                label: AppStrings.clientEmail,
                                keyboardType: TextInputType.emailAddress,
                                required: true,
                              ),
                              const SizedBox(height: AppDimensions.spacingM),
                              _buildField(
                                controller: _phoneCtrl,
                                label: AppStrings.clientPhone,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: AppDimensions.spacingM),
                              _buildField(
                                controller: _companyCtrl,
                                label: AppStrings.clientCompany,
                              ),
                              const SizedBox(height: AppDimensions.spacingM),
                              _buildField(
                                controller: _addressCtrl,
                                label: AppStrings.clientAddress,
                                maxLines: 3,
                              ),
                              const SizedBox(height: AppDimensions.spacingXL),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    onPressed: () => context.go('/clients'),
                                    child: const Text(AppStrings.cancel),
                                  ),
                                  const SizedBox(width: AppDimensions.spacingM),
                                  BlocBuilder<ClientFormCubit, ClientFormState>(
                                    builder: (context, state) {
                                      final isSaving = state is ClientFormSaving;
                                      return ElevatedButton(
                                        onPressed: isSaving ? null : _submit,
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

  Widget _buildHeader(BuildContext context, bool isEdit) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/clients'),
        ),
        const SizedBox(width: AppDimensions.spacingS),
        Text(
          isEdit ? AppStrings.clientEdit : AppStrings.clientCreate,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool required = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
      validator: required
          ? (v) =>
              v == null || v.trim().isEmpty ? '$label wajib diisi' : null
          : null,
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ClientFormCubit>().submit(
          existingId: widget.clientId,
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          company: _companyCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
        );
  }
}
