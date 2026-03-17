import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/page_entity.dart';
import '../repositories/page_repository.dart';

/// Use case untuk membuat halaman baru.
class CreatePageUseCase {
  final PageRepository _repository;

  const CreatePageUseCase(this._repository);

  /// Returns [Right(void)] jika berhasil.
  Future<Either<Failure, void>> call(PageEntity pageEntity) {
    return _repository.createPage(pageEntity);
  }
}
