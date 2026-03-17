import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/content.dart';

/// Interface repository untuk konten.
abstract class ContentRepository {
  /// Ambil daftar konten.
  Future<Either<Failure, List<Content>>> getContents({
    String? search,
    String? status,
    int page = 1,
    int limit = 20,
  });

  /// Ambil detail konten berdasarkan [id].
  Future<Either<Failure, Content>> getContentById(String id);

  /// Buat konten baru.
  Future<Either<Failure, void>> createContent(Content content);

  /// Perbarui konten yang sudah ada.
  Future<Either<Failure, void>> updateContent(Content content);

  /// Publikasikan konten (draft -> published).
  Future<Either<Failure, void>> publishContent(String id);

  /// Hapus konten berdasarkan [id].
  Future<Either<Failure, void>> deleteContent(String id);
}
