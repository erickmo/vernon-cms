import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/page_entity.dart';
import '../repositories/page_repository.dart';

/// Use case untuk mengambil daftar halaman.
class GetPagesUseCase {
  final PageRepository _repository;

  const GetPagesUseCase(this._repository);

  /// Returns [Right(List<PageEntity>)] jika berhasil.
  Future<Either<Failure, List<PageEntity>>> call({
    String? search,
    int page = 1,
    int limit = 20,
  }) {
    return _repository.getPages(
      search: search,
      page: page,
      limit: limit,
    );
  }
}
