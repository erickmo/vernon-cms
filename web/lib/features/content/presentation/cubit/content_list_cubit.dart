import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/content.dart';
import '../../domain/usecases/delete_content_usecase.dart';
import '../../domain/usecases/get_contents_usecase.dart';
import '../../domain/usecases/publish_content_usecase.dart';

part 'content_list_state.dart';
part 'content_list_cubit.freezed.dart';

/// Cubit untuk mengelola state halaman daftar konten.
class ContentListCubit extends Cubit<ContentListState> {
  final GetContentsUseCase _getContentsUseCase;
  final DeleteContentUseCase _deleteContentUseCase;
  final PublishContentUseCase _publishContentUseCase;

  ContentListCubit({
    required GetContentsUseCase getContentsUseCase,
    required DeleteContentUseCase deleteContentUseCase,
    required PublishContentUseCase publishContentUseCase,
  })  : _getContentsUseCase = getContentsUseCase,
        _deleteContentUseCase = deleteContentUseCase,
        _publishContentUseCase = publishContentUseCase,
        super(const ContentListState.initial());

  /// Memuat daftar konten.
  Future<void> loadContents({
    String? search,
    String? status,
  }) async {
    emit(const ContentListState.loading());

    final result = await _getContentsUseCase(
      search: search,
      status: status,
    );

    result.fold(
      (failure) => emit(ContentListState.error(failure.message)),
      (contents) => emit(ContentListState.loaded(
        contents: contents,
        searchQuery: search ?? '',
        statusFilter: status ?? '',
      )),
    );
  }

  /// Mempublikasikan konten berdasarkan [id].
  Future<bool> publishContent(String id) async {
    final result = await _publishContentUseCase(id);

    return result.fold(
      (failure) {
        emit(ContentListState.error(failure.message));
        return false;
      },
      (_) {
        _reloadCurrentFilters();
        return true;
      },
    );
  }

  /// Menghapus konten berdasarkan [id].
  Future<bool> deleteContent(String id) async {
    final result = await _deleteContentUseCase(id);

    return result.fold(
      (failure) {
        emit(ContentListState.error(failure.message));
        return false;
      },
      (_) {
        _reloadCurrentFilters();
        return true;
      },
    );
  }

  void _reloadCurrentFilters() {
    final currentState = state;
    final search = currentState is ContentListLoaded
        ? currentState.searchQuery
        : null;
    final status = currentState is ContentListLoaded
        ? currentState.statusFilter
        : null;
    loadContents(
      search: search?.isNotEmpty == true ? search : null,
      status: status?.isNotEmpty == true ? status : null,
    );
  }
}
