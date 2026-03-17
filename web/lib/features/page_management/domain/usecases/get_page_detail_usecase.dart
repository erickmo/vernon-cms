import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/page_entity.dart';
import '../repositories/page_repository.dart';

/// Use case untuk mengambil detail halaman.
class GetPageDetailUseCase {
  final PageRepository _repository;

  const GetPageDetailUseCase(this._repository);

  /// Returns [Right(PageEntity)] jika berhasil.
  Future<Either<Failure, PageEntity>> call(String id) {
    return _repository.getPageById(id);
  }
}
