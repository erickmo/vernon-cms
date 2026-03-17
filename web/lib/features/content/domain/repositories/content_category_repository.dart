import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/content_category.dart';

/// Interface repository untuk kategori konten.
abstract class ContentCategoryRepository {
  /// Ambil daftar kategori konten.
  Future<Either<Failure, List<ContentCategory>>> getCategories({
    int page = 1,
    int limit = 20,
  });

  /// Ambil detail kategori berdasarkan [id].
  Future<Either<Failure, ContentCategory>> getCategoryById(String id);

  /// Buat kategori baru.
  Future<Either<Failure, void>> createCategory(ContentCategory category);

  /// Perbarui kategori yang sudah ada.
  Future<Either<Failure, void>> updateCategory(ContentCategory category);

  /// Hapus kategori berdasarkan [id].
  Future<Either<Failure, void>> deleteCategory(String id);
}
