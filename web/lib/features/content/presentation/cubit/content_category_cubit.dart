import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/content_category.dart';
import '../../domain/usecases/create_content_category_usecase.dart';
import '../../domain/usecases/delete_content_category_usecase.dart';
import '../../domain/usecases/get_content_categories_usecase.dart';
import '../../domain/usecases/update_content_category_usecase.dart';

part 'content_category_state.dart';
part 'content_category_cubit.freezed.dart';

/// Cubit untuk mengelola state halaman kategori konten.
class ContentCategoryCubit extends Cubit<ContentCategoryState> {
  final GetContentCategoriesUseCase _getCategoriesUseCase;
  final CreateContentCategoryUseCase _createCategoryUseCase;
  final UpdateContentCategoryUseCase _updateCategoryUseCase;
  final DeleteContentCategoryUseCase _deleteCategoryUseCase;

  ContentCategoryCubit({
    required GetContentCategoriesUseCase getCategoriesUseCase,
    required CreateContentCategoryUseCase createCategoryUseCase,
    required UpdateContentCategoryUseCase updateCategoryUseCase,
    required DeleteContentCategoryUseCase deleteCategoryUseCase,
  })  : _getCategoriesUseCase = getCategoriesUseCase,
        _createCategoryUseCase = createCategoryUseCase,
        _updateCategoryUseCase = updateCategoryUseCase,
        _deleteCategoryUseCase = deleteCategoryUseCase,
        super(const ContentCategoryState.initial());

  /// Memuat daftar kategori konten.
  Future<void> loadCategories() async {
    emit(const ContentCategoryState.loading());

    final result = await _getCategoriesUseCase();

    result.fold(
      (failure) => emit(ContentCategoryState.error(failure.message)),
      (categories) => emit(ContentCategoryState.loaded(
        categories: categories,
      )),
    );
  }

  /// Membuat kategori konten baru.
  Future<bool> createCategory(ContentCategory category) async {
    final result = await _createCategoryUseCase(category);

    return result.fold(
      (failure) {
        emit(ContentCategoryState.error(failure.message));
        return false;
      },
      (_) {
        loadCategories();
        return true;
      },
    );
  }

  /// Memperbarui kategori konten.
  Future<bool> updateCategory(ContentCategory category) async {
    final result = await _updateCategoryUseCase(category);

    return result.fold(
      (failure) {
        emit(ContentCategoryState.error(failure.message));
        return false;
      },
      (_) {
        loadCategories();
        return true;
      },
    );
  }

  /// Menghapus kategori konten berdasarkan [id].
  Future<bool> deleteCategory(String id) async {
    final result = await _deleteCategoryUseCase(id);

    return result.fold(
      (failure) {
        emit(ContentCategoryState.error(failure.message));
        return false;
      },
      (_) {
        loadCategories();
        return true;
      },
    );
  }
}
