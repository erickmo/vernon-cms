import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/domain_definition.dart';
import '../../domain/usecases/create_domain_usecase.dart';
import '../../domain/usecases/get_domain_detail_usecase.dart';
import '../../domain/usecases/update_domain_usecase.dart';

part 'domain_form_state.dart';
part 'domain_form_cubit.freezed.dart';

/// Cubit untuk mengelola state form domain builder (create/edit).
class DomainFormCubit extends Cubit<DomainFormState> {
  final GetDomainDetailUseCase _getDomainDetailUseCase;
  final CreateDomainUseCase _createDomainUseCase;
  final UpdateDomainUseCase _updateDomainUseCase;

  DomainFormCubit({
    required GetDomainDetailUseCase getDomainDetailUseCase,
    required CreateDomainUseCase createDomainUseCase,
    required UpdateDomainUseCase updateDomainUseCase,
  })  : _getDomainDetailUseCase = getDomainDetailUseCase,
        _createDomainUseCase = createDomainUseCase,
        _updateDomainUseCase = updateDomainUseCase,
        super(const DomainFormState.initial());

  /// Memuat detail domain untuk editing.
  Future<void> loadDomain(String id) async {
    emit(const DomainFormState.loading());

    final result = await _getDomainDetailUseCase(id);

    result.fold(
      (failure) => emit(DomainFormState.error(failure.message)),
      (domain) => emit(DomainFormState.loaded(domain: domain)),
    );
  }

  /// Membuat domain baru.
  Future<bool> createDomain(DomainDefinition domain) async {
    emit(const DomainFormState.saving());

    final result = await _createDomainUseCase(domain);

    return result.fold(
      (failure) {
        emit(DomainFormState.error(failure.message));
        return false;
      },
      (savedDomain) {
        emit(DomainFormState.saved(domain: savedDomain));
        return true;
      },
    );
  }

  /// Memperbarui domain yang sudah ada.
  Future<bool> updateDomain(DomainDefinition domain) async {
    emit(const DomainFormState.saving());

    final result = await _updateDomainUseCase(domain);

    return result.fold(
      (failure) {
        emit(DomainFormState.error(failure.message));
        return false;
      },
      (savedDomain) {
        emit(DomainFormState.saved(domain: savedDomain));
        return true;
      },
    );
  }
}
