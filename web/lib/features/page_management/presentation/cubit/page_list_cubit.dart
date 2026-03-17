import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/page_entity.dart';
import '../../domain/usecases/delete_page_usecase.dart';
import '../../domain/usecases/get_pages_usecase.dart';

part 'page_list_state.dart';
part 'page_list_cubit.freezed.dart';

/// Cubit untuk mengelola state halaman daftar halaman CMS.
class PageListCubit extends Cubit<PageListState> {
  final GetPagesUseCase _getPagesUseCase;
  final DeletePageUseCase _deletePageUseCase;

  PageListCubit({
    required GetPagesUseCase getPagesUseCase,
    required DeletePageUseCase deletePageUseCase,
  })  : _getPagesUseCase = getPagesUseCase,
        _deletePageUseCase = deletePageUseCase,
        super(const PageListState.initial());

  /// Memuat daftar halaman.
  Future<void> loadPages({String? search}) async {
    emit(const PageListState.loading());

    final result = await _getPagesUseCase(search: search);

    result.fold(
      (failure) => emit(PageListState.error(failure.message)),
      (pages) => emit(PageListState.loaded(
        pages: pages,
        searchQuery: search ?? '',
      )),
    );
  }

  /// Menghapus halaman berdasarkan [id].
  Future<bool> deletePage(String id) async {
    final result = await _deletePageUseCase(id);

    return result.fold(
      (failure) {
        emit(PageListState.error(failure.message));
        return false;
      },
      (_) {
        // Refresh daftar setelah berhasil menghapus halaman.
        final currentSearch = state is PageListLoaded
            ? (state as PageListLoaded).searchQuery
            : null;
        loadPages(search: currentSearch);
        return true;
      },
    );
  }
}
