import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/page_repository.dart';

/// Use case untuk menghapus halaman.
class DeletePageUseCase {
  final PageRepository _repository;

  const DeletePageUseCase(this._repository);

  /// Returns [Right(void)] jika berhasil.
  Future<Either<Failure, void>> call(String id) {
    return _repository.deletePage(id);
  }
}
