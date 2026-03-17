import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/page_entity.dart';

/// Interface repository untuk halaman CMS.
abstract class PageRepository {
  /// Ambil daftar halaman.
  Future<Either<Failure, List<PageEntity>>> getPages({
    String? search,
    int page = 1,
    int limit = 20,
  });

  /// Ambil detail halaman berdasarkan [id].
  Future<Either<Failure, PageEntity>> getPageById(String id);

  /// Buat halaman baru.
  Future<Either<Failure, void>> createPage(PageEntity pageEntity);

  /// Perbarui halaman yang sudah ada.
  Future<Either<Failure, void>> updatePage(PageEntity pageEntity);

  /// Hapus halaman berdasarkan [id].
  Future<Either<Failure, void>> deletePage(String id);
}
