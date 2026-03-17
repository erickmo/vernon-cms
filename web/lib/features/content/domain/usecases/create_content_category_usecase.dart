import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/content_category.dart';
import '../repositories/content_category_repository.dart';

/// Use case untuk membuat kategori konten baru.
class CreateContentCategoryUseCase {
  final ContentCategoryRepository _repository;

  const CreateContentCategoryUseCase(this._repository);

  /// Returns [Right(void)] jika berhasil.
  Future<Either<Failure, void>> call(ContentCategory category) {
    return _repository.createCategory(category);
  }
}
