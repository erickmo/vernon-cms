import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/payment.dart';
import '../../domain/usecases/get_payments_usecase.dart';

part 'payment_list_state.dart';
part 'payment_list_cubit.freezed.dart';

class PaymentListCubit extends Cubit<PaymentListState> {
  final GetPaymentsUseCase _getPaymentsUseCase;

  PaymentListCubit({required GetPaymentsUseCase getPaymentsUseCase})
      : _getPaymentsUseCase = getPaymentsUseCase,
        super(const PaymentListState.initial());

  Future<void> loadPayments({
    String? clientId,
    PaymentStatus? status,
  }) async {
    emit(const PaymentListState.loading());
    final result = await _getPaymentsUseCase(clientId: clientId, status: status);
    result.fold(
      (failure) => emit(PaymentListState.error(failure.message)),
      (payments) => emit(PaymentListState.loaded(
        payments: payments,
        clientIdFilter: clientId,
        statusFilter: status,
      )),
    );
  }
}
