import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain_builder/domain/entities/domain_definition.dart';
import '../../domain/entities/domain_record.dart';
import '../../domain/usecases/delete_domain_record_usecase.dart';
import '../../domain/usecases/get_domain_records_usecase.dart';

part 'domain_record_list_state.dart';
part 'domain_record_list_cubit.freezed.dart';

/// Cubit untuk mengelola state halaman daftar record domain.
class DomainRecordListCubit extends Cubit<DomainRecordListState> {
  final GetDomainRecordsUseCase _getRecordsUseCase;
  final DeleteDomainRecordUseCase _deleteRecordUseCase;

  DomainRecordListCubit({
    required GetDomainRecordsUseCase getRecordsUseCase,
    required DeleteDomainRecordUseCase deleteRecordUseCase,
  })  : _getRecordsUseCase = getRecordsUseCase,
        _deleteRecordUseCase = deleteRecordUseCase,
        super(const DomainRecordListState.initial());

  /// Memuat daftar record domain.
  Future<void> loadRecords({
    required String domainSlug,
    required DomainDefinition domain,
    String? search,
  }) async {
    emit(const DomainRecordListState.loading());

    final result = await _getRecordsUseCase(
      domainSlug: domainSlug,
      search: search,
    );

    result.fold(
      (failure) => emit(DomainRecordListState.error(failure.message)),
      (records) => emit(DomainRecordListState.loaded(
        domain: domain,
        records: records,
        searchQuery: search ?? '',
      )),
    );
  }

  /// Menghapus record berdasarkan [id].
  Future<bool> deleteRecord({
    required String domainSlug,
    required String id,
  }) async {
    final result = await _deleteRecordUseCase(
      domainSlug: domainSlug,
      id: id,
    );

    return result.fold(
      (failure) {
        emit(DomainRecordListState.error(failure.message));
        return false;
      },
      (_) {
        // Refresh daftar setelah berhasil menghapus record.
        final currentState = state;
        if (currentState is DomainRecordListLoaded) {
          loadRecords(
            domainSlug: domainSlug,
            domain: currentState.domain,
            search: currentState.searchQuery.isNotEmpty
                ? currentState.searchQuery
                : null,
          );
        }
        return true;
      },
    );
  }
}
