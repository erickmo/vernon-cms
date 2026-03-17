import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/domain_definition.dart';
import '../../domain/usecases/delete_domain_usecase.dart';
import '../../domain/usecases/get_domains_usecase.dart';

part 'domain_builder_state.dart';
part 'domain_builder_cubit.freezed.dart';

/// Cubit untuk mengelola state halaman daftar domain builder.
class DomainBuilderCubit extends Cubit<DomainBuilderState> {
  final GetDomainsUseCase _getDomainsUseCase;
  final DeleteDomainUseCase _deleteDomainUseCase;

  DomainBuilderCubit({
    required GetDomainsUseCase getDomainsUseCase,
    required DeleteDomainUseCase deleteDomainUseCase,
  })  : _getDomainsUseCase = getDomainsUseCase,
        _deleteDomainUseCase = deleteDomainUseCase,
        super(const DomainBuilderState.initial());

  /// Memuat daftar domain.
  Future<void> loadDomains() async {
    emit(const DomainBuilderState.loading());

    final result = await _getDomainsUseCase();

    result.fold(
      (failure) => emit(DomainBuilderState.error(failure.message)),
      (domains) => emit(DomainBuilderState.loaded(domains: domains)),
    );
  }

  /// Menghapus domain berdasarkan [id].
  Future<bool> deleteDomain(String id) async {
    final result = await _deleteDomainUseCase(id);

    return result.fold(
      (failure) {
        emit(DomainBuilderState.error(failure.message));
        return false;
      },
      (_) {
        // Refresh daftar setelah berhasil menghapus domain.
        loadDomains();
        return true;
      },
    );
  }
}
