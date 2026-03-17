part of 'payment_detail_cubit.dart';

@freezed
sealed class PaymentDetailState with _$PaymentDetailState {
  const factory PaymentDetailState.initial() = PaymentDetailInitial;
  const factory PaymentDetailState.loading() = PaymentDetailLoading;
  const factory PaymentDetailState.loaded(Payment payment) = PaymentDetailLoaded;
  const factory PaymentDetailState.error(String message) = PaymentDetailError;
}
