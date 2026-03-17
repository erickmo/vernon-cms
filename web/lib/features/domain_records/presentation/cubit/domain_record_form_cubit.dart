import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/domain_record.dart';
import '../../domain/usecases/create_domain_record_usecase.dart';
import '../../domain/usecases/get_domain_record_detail_usecase.dart';
import '../../domain/usecases/update_domain_record_usecase.dart';

part 'domain_record_form_state.dart';
part 'domain_record_form_cubit.freezed.dart';

/// Cubit untuk mengelola state form record domain (create/edit).
class DomainRecordFormCubit extends Cubit<DomainRecordFormState> {
  final GetDomainRecordDetailUseCase _getRecordDetailUseCase;
  final CreateDomainRecordUseCase _createRecordUseCase;
  final UpdateDomainRecordUseCase _updateRecordUseCase;

  DomainRecordFormCubit({
    required GetDomainRecordDetailUseCase getRecordDetailUseCase,
    required CreateDomainRecordUseCase createRecordUseCase,
    required UpdateDomainRecordUseCase updateRecordUseCase,
  })  : _getRecordDetailUseCase = getRecordDetailUseCase,
        _createRecordUseCase = createRecordUseCase,
        _updateRecordUseCase = updateRecordUseCase,
        super(const DomainRecordFormState.initial());

  /// Memuat detail record untuk editing.
  Future<void> loadRecord({
    required String domainSlug,
    required String id,
  }) async {
    emit(const DomainRecordFormState.loading());

    final result = await _getRecordDetailUseCase(
      domainSlug: domainSlug,
      id: id,
    );

    result.fold(
      (failure) => emit(DomainRecordFormState.error(failure.message)),
      (record) => emit(DomainRecordFormState.loaded(record: record)),
    );
  }

  /// Membuat record baru.
  Future<bool> createRecord({
    required String domainSlug,
    required Map<String, dynamic> data,
  }) async {
    emit(const DomainRecordFormState.saving());

    final result = await _createRecordUseCase(
      domainSlug: domainSlug,
      data: data,
    );

    return result.fold(
      (failure) {
        emit(DomainRecordFormState.error(failure.message));
        return false;
      },
      (record) {
        emit(DomainRecordFormState.saved(record: record));
        return true;
      },
    );
  }

  /// Memperbarui record yang sudah ada.
  Future<bool> updateRecord({
    required String domainSlug,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    emit(const DomainRecordFormState.saving());

    final result = await _updateRecordUseCase(
      domainSlug: domainSlug,
      id: id,
      data: data,
    );

    return result.fold(
      (failure) {
        emit(DomainRecordFormState.error(failure.message));
        return false;
      },
      (record) {
        emit(DomainRecordFormState.saved(record: record));
        return true;
      },
    );
  }
}
