part of 'payment_list_cubit.dart';

@freezed
sealed class PaymentListState with _$PaymentListState {
  const factory PaymentListState.initial() = PaymentListInitial;
  const factory PaymentListState.loading() = PaymentListLoading;
  const factory PaymentListState.loaded({
    required List<Payment> payments,
    String? clientIdFilter,
    PaymentStatus? statusFilter,
  }) = PaymentListLoaded;
  const factory PaymentListState.error(String message) = PaymentListError;
}
