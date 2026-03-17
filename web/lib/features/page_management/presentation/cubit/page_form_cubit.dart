import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/page_entity.dart';
import '../../domain/usecases/create_page_usecase.dart';
import '../../domain/usecases/get_page_detail_usecase.dart';
import '../../domain/usecases/update_page_usecase.dart';

part 'page_form_state.dart';
part 'page_form_cubit.freezed.dart';

/// Cubit untuk mengelola state form halaman CMS (create/edit).
class PageFormCubit extends Cubit<PageFormState> {
  final GetPageDetailUseCase _getPageDetailUseCase;
  final CreatePageUseCase _createPageUseCase;
  final UpdatePageUseCase _updatePageUseCase;

  PageFormCubit({
    required GetPageDetailUseCase getPageDetailUseCase,
    required CreatePageUseCase createPageUseCase,
    required UpdatePageUseCase updatePageUseCase,
  })  : _getPageDetailUseCase = getPageDetailUseCase,
        _createPageUseCase = createPageUseCase,
        _updatePageUseCase = updatePageUseCase,
        super(const PageFormState.initial());

  /// Memuat detail halaman untuk mode edit.
  Future<void> loadPage(String id) async {
    emit(const PageFormState.loading());

    final result = await _getPageDetailUseCase(id);

    result.fold(
      (failure) => emit(PageFormState.error(failure.message)),
      (page) => emit(PageFormState.loaded(page: page)),
    );
  }

  /// Membuat halaman baru.
  Future<bool> createPage(PageEntity pageEntity) async {
    emit(const PageFormState.saving());

    final result = await _createPageUseCase(pageEntity);

    return result.fold(
      (failure) {
        emit(PageFormState.error(failure.message));
        return false;
      },
      (_) {
        emit(const PageFormState.saved());
        return true;
      },
    );
  }

  /// Memperbarui halaman.
  Future<bool> updatePage(PageEntity pageEntity) async {
    emit(const PageFormState.saving());

    final result = await _updatePageUseCase(pageEntity);

    return result.fold(
      (failure) {
        emit(PageFormState.error(failure.message));
        return false;
      },
      (_) {
        emit(const PageFormState.saved());
        return true;
      },
    );
  }
}
