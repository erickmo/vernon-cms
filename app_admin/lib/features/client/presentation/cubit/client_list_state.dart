part of 'client_list_cubit.dart';

@freezed
sealed class ClientListState with _$ClientListState {
  const factory ClientListState.initial() = ClientListInitial;
  const factory ClientListState.loading() = ClientListLoading;
  const factory ClientListState.loaded({
    required List<Client> clients,
    @Default('') String searchQuery,
    bool? isActiveFilter,
  }) = ClientListLoaded;
  const factory ClientListState.error(String message) = ClientListError;
}
