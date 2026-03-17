part of 'payment_form_cubit.dart';

@freezed
sealed class PaymentFormState with _$PaymentFormState {
  const factory PaymentFormState.initial() = PaymentFormInitial;
  const factory PaymentFormState.loading() = PaymentFormLoading;
  const factory PaymentFormState.ready({
    required List<Client> clients,
  }) = PaymentFormReady;
  const factory PaymentFormState.saving() = PaymentFormSaving;
  const factory PaymentFormState.success(String message) = PaymentFormSuccess;
  const factory PaymentFormState.error(String message) = PaymentFormError;
}
