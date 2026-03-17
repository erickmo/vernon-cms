import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/client.dart';
import '../../domain/usecases/delete_client_usecase.dart';
import '../../domain/usecases/get_clients_usecase.dart';
import '../../domain/usecases/toggle_client_active_usecase.dart';

part 'client_list_state.dart';
part 'client_list_cubit.freezed.dart';

class ClientListCubit extends Cubit<ClientListState> {
  final GetClientsUseCase _getClientsUseCase;
  final DeleteClientUseCase _deleteClientUseCase;
  final ToggleClientActiveUseCase _toggleClientActiveUseCase;

  ClientListCubit({
    required GetClientsUseCase getClientsUseCase,
    required DeleteClientUseCase deleteClientUseCase,
    required ToggleClientActiveUseCase toggleClientActiveUseCase,
  })  : _getClientsUseCase = getClientsUseCase,
        _deleteClientUseCase = deleteClientUseCase,
        _toggleClientActiveUseCase = toggleClientActiveUseCase,
        super(const ClientListState.initial());

  Future<void> loadClients({String? search, bool? isActive}) async {
    emit(const ClientListState.loading());
    final result =
        await _getClientsUseCase(search: search, isActive: isActive);
    result.fold(
      (failure) => emit(ClientListState.error(failure.message)),
      (clients) => emit(ClientListState.loaded(
        clients: clients,
        searchQuery: search ?? '',
        isActiveFilter: isActive,
      )),
    );
  }

  Future<bool> deleteClient(String id) async {
    final result = await _deleteClientUseCase(id);
    return result.fold(
      (failure) {
        emit(ClientListState.error(failure.message));
        return false;
      },
      (_) {
        _reload();
        return true;
      },
    );
  }

  Future<bool> toggleActive(String id) async {
    final result = await _toggleClientActiveUseCase(id);
    return result.fold(
      (failure) {
        emit(ClientListState.error(failure.message));
        return false;
      },
      (_) {
        _reload();
        return true;
      },
    );
  }

  void _reload() {
    final s = state;
    loadClients(
      search: s is ClientListLoaded && s.searchQuery.isNotEmpty
          ? s.searchQuery
          : null,
      isActive: s is ClientListLoaded ? s.isActiveFilter : null,
    );
  }
}
