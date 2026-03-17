import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/content_category_repository.dart';

/// Use case untuk menghapus kategori konten.
class DeleteContentCategoryUseCase {
  final ContentCategoryRepository _repository;

  const DeleteContentCategoryUseCase(this._repository);

  /// Returns [Right(void)] jika berhasil.
  Future<Either<Failure, void>> call(String id) {
    return _repository.deleteCategory(id);
  }
}
