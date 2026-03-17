import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/content_category.dart';
import '../repositories/content_category_repository.dart';

/// Use case untuk mengambil daftar kategori konten.
class GetContentCategoriesUseCase {
  final ContentCategoryRepository _repository;

  const GetContentCategoriesUseCase(this._repository);

  /// Returns [Right(List<ContentCategory>)] jika berhasil.
  Future<Either<Failure, List<ContentCategory>>> call({
    int page = 1,
    int limit = 20,
  }) {
    return _repository.getCategories(
      page: page,
      limit: limit,
    );
  }
}
