import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/client.dart';
import '../../domain/usecases/delete_client_usecase.dart';
import '../../domain/usecases/get_client_usecase.dart';
import '../../domain/usecases/toggle_client_active_usecase.dart';

part 'client_detail_state.dart';
part 'client_detail_cubit.freezed.dart';

class ClientDetailCubit extends Cubit<ClientDetailState> {
  final GetClientUseCase _getClientUseCase;
  final ToggleClientActiveUseCase _toggleClientActiveUseCase;
  final DeleteClientUseCase _deleteClientUseCase;

  ClientDetailCubit({
    required GetClientUseCase getClientUseCase,
    required ToggleClientActiveUseCase toggleClientActiveUseCase,
    required DeleteClientUseCase deleteClientUseCase,
  })  : _getClientUseCase = getClientUseCase,
        _toggleClientActiveUseCase = toggleClientActiveUseCase,
        _deleteClientUseCase = deleteClientUseCase,
        super(const ClientDetailState.initial());

  Future<void> loadClient(String id) async {
    emit(const ClientDetailState.loading());
    final result = await _getClientUseCase(id);
    result.fold(
      (failure) => emit(ClientDetailState.error(failure.message)),
      (client) => emit(ClientDetailState.loaded(client)),
    );
  }

  Future<bool> toggleActive(String id) async {
    final result = await _toggleClientActiveUseCase(id);
    return result.fold(
      (failure) {
        emit(ClientDetailState.error(failure.message));
        return false;
      },
      (_) {
        loadClient(id);
        return true;
      },
    );
  }

  Future<bool> deleteClient(String id) async {
    final result = await _deleteClientUseCase(id);
    return result.fold(
      (failure) {
        emit(ClientDetailState.error(failure.message));
        return false;
      },
      (_) => true,
    );
  }
}
