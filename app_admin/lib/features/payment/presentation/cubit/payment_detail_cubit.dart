import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/payment.dart';
import '../../domain/usecases/get_payment_usecase.dart';

part 'payment_detail_state.dart';
part 'payment_detail_cubit.freezed.dart';

class PaymentDetailCubit extends Cubit<PaymentDetailState> {
  final GetPaymentUseCase _getPaymentUseCase;

  PaymentDetailCubit({required GetPaymentUseCase getPaymentUseCase})
      : _getPaymentUseCase = getPaymentUseCase,
        super(const PaymentDetailState.initial());

  Future<void> loadPayment(String id) async {
    emit(const PaymentDetailState.loading());
    final result = await _getPaymentUseCase(id);
    result.fold(
      (failure) => emit(PaymentDetailState.error(failure.message)),
      (payment) => emit(PaymentDetailState.loaded(payment)),
    );
  }
}
