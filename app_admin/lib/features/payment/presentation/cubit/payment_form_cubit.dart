import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../client/domain/entities/client.dart';
import '../../../client/domain/usecases/get_clients_usecase.dart';
import '../../domain/entities/payment_params.dart';
import '../../domain/usecases/create_payment_usecase.dart';

part 'payment_form_state.dart';
part 'payment_form_cubit.freezed.dart';

class PaymentFormCubit extends Cubit<PaymentFormState> {
  final CreatePaymentUseCase _createPaymentUseCase;
  final GetClientsUseCase _getClientsUseCase;

  PaymentFormCubit({
    required CreatePaymentUseCase createPaymentUseCase,
    required GetClientsUseCase getClientsUseCase,
  })  : _createPaymentUseCase = createPaymentUseCase,
        _getClientsUseCase = getClientsUseCase,
        super(const PaymentFormState.initial());

  Future<void> loadClients() async {
    emit(const PaymentFormState.loading());
    final result = await _getClientsUseCase(isActive: true);
    result.fold(
      (failure) => emit(PaymentFormState.error(failure.message)),
      (clients) => emit(PaymentFormState.ready(clients: clients)),
    );
  }

  Future<void> submit({
    required String clientId,
    required double amount,
    String? description,
    String? method,
    DateTime? dueDate,
  }) async {
    emit(const PaymentFormState.saving());
    final result = await _createPaymentUseCase(CreatePaymentParams(
      clientId: clientId,
      amount: amount,
      description: description?.isNotEmpty == true ? description : null,
      method: method?.isNotEmpty == true ? method : null,
      dueDate: dueDate,
    ));
    result.fold(
      (failure) => emit(PaymentFormState.error(failure.message)),
      (_) => emit(const PaymentFormState.success(AppStrings.paymentCreated)),
    );
  }
}
