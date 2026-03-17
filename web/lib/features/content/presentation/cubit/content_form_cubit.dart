import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/content.dart';
import '../../domain/usecases/create_content_usecase.dart';
import '../../domain/usecases/get_content_detail_usecase.dart';
import '../../domain/usecases/update_content_usecase.dart';

part 'content_form_state.dart';
part 'content_form_cubit.freezed.dart';

/// Cubit untuk mengelola state form konten (create/edit).
class ContentFormCubit extends Cubit<ContentFormState> {
  final GetContentDetailUseCase _getContentDetailUseCase;
  final CreateContentUseCase _createContentUseCase;
  final UpdateContentUseCase _updateContentUseCase;

  ContentFormCubit({
    required GetContentDetailUseCase getContentDetailUseCase,
    required CreateContentUseCase createContentUseCase,
    required UpdateContentUseCase updateContentUseCase,
  })  : _getContentDetailUseCase = getContentDetailUseCase,
        _createContentUseCase = createContentUseCase,
        _updateContentUseCase = updateContentUseCase,
        super(const ContentFormState.initial());

  /// Memuat detail konten untuk editing.
  Future<void> loadContent(String id) async {
    emit(const ContentFormState.loading());

    final result = await _getContentDetailUseCase(id);

    result.fold(
      (failure) => emit(ContentFormState.error(failure.message)),
      (content) => emit(ContentFormState.loaded(content: content)),
    );
  }

  /// Membuat konten baru.
  Future<bool> createContent(Content content) async {
    emit(const ContentFormState.saving());

    final result = await _createContentUseCase(content);

    return result.fold(
      (failure) {
        emit(ContentFormState.error(failure.message));
        return false;
      },
      (_) {
        emit(const ContentFormState.saved());
        return true;
      },
    );
  }

  /// Memperbarui konten yang sudah ada.
  Future<bool> updateContent(Content content) async {
    emit(const ContentFormState.saving());

    final result = await _updateContentUseCase(content);

    return result.fold(
      (failure) {
        emit(ContentFormState.error(failure.message));
        return false;
      },
      (_) {
        emit(const ContentFormState.saved());
        return true;
      },
    );
  }
}
