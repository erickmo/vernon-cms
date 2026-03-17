import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/page_entity.dart';
import '../repositories/page_repository.dart';

/// Use case untuk memperbarui halaman.
class UpdatePageUseCase {
  final PageRepository _repository;

  const UpdatePageUseCase(this._repository);

  /// Returns [Right(void)] jika berhasil.
  Future<Either<Failure, void>> call(PageEntity pageEntity) {
    return _repository.updatePage(pageEntity);
  }
}
