part of 'client_detail_cubit.dart';

@freezed
sealed class ClientDetailState with _$ClientDetailState {
  const factory ClientDetailState.initial() = ClientDetailInitial;
  const factory ClientDetailState.loading() = ClientDetailLoading;
  const factory ClientDetailState.loaded(Client client) = ClientDetailLoaded;
  const factory ClientDetailState.error(String message) = ClientDetailError;
}
