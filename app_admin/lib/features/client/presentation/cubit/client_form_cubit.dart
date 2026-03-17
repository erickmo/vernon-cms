import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/client.dart';
import '../../domain/entities/client_params.dart';
import '../../domain/usecases/create_client_usecase.dart';
import '../../domain/usecases/get_client_usecase.dart';
import '../../domain/usecases/update_client_usecase.dart';

part 'client_form_state.dart';
part 'client_form_cubit.freezed.dart';

class ClientFormCubit extends Cubit<ClientFormState> {
  final CreateClientUseCase _createClientUseCase;
  final UpdateClientUseCase _updateClientUseCase;
  final GetClientUseCase _getClientUseCase;

  ClientFormCubit({
    required CreateClientUseCase createClientUseCase,
    required UpdateClientUseCase updateClientUseCase,
    required GetClientUseCase getClientUseCase,
  })  : _createClientUseCase = createClientUseCase,
        _updateClientUseCase = updateClientUseCase,
        _getClientUseCase = getClientUseCase,
        super(const ClientFormState.initial());

  Future<void> loadClient(String id) async {
    emit(const ClientFormState.loadingData());
    final result = await _getClientUseCase(id);
    result.fold(
      (failure) => emit(ClientFormState.error(failure.message)),
      (client) => emit(ClientFormState.ready(existingClient: client)),
    );
  }

  void initCreate() => emit(const ClientFormState.ready());

  Future<void> submit({
    String? existingId,
    required String name,
    required String email,
    String? phone,
    String? company,
    String? address,
  }) async {
    emit(const ClientFormState.saving());

    if (existingId != null) {
      final result = await _updateClientUseCase(UpdateClientParams(
        id: existingId,
        name: name,
        email: email,
        phone: phone?.isNotEmpty == true ? phone : null,
        company: company?.isNotEmpty == true ? company : null,
        address: address?.isNotEmpty == true ? address : null,
      ));
      result.fold(
        (failure) => emit(ClientFormState.error(failure.message)),
        (_) => emit(const ClientFormState.success(AppStrings.clientUpdated)),
      );
    } else {
      final result = await _createClientUseCase(CreateClientParams(
        name: name,
        email: email,
        phone: phone?.isNotEmpty == true ? phone : null,
        company: company?.isNotEmpty == true ? company : null,
        address: address?.isNotEmpty == true ? address : null,
      ));
      result.fold(
        (failure) => emit(ClientFormState.error(failure.message)),
        (_) => emit(const ClientFormState.success(AppStrings.clientCreated)),
      );
    }
  }
}
