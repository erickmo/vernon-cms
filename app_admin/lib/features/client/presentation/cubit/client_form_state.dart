part of 'client_form_cubit.dart';

@freezed
sealed class ClientFormState with _$ClientFormState {
  const factory ClientFormState.initial() = ClientFormInitial;
  const factory ClientFormState.loadingData() = ClientFormLoadingData;
  const factory ClientFormState.ready({Client? existingClient}) = ClientFormReady;
  const factory ClientFormState.saving() = ClientFormSaving;
  const factory ClientFormState.success(String message) = ClientFormSuccess;
  const factory ClientFormState.error(String message) = ClientFormError;
}
