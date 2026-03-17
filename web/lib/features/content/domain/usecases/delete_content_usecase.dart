import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/content_repository.dart';

/// Use case untuk menghapus konten.
class DeleteContentUseCase {
  final ContentRepository _repository;

  const DeleteContentUseCase(this._repository);

  /// Returns [Right(void)] jika berhasil.
  Future<Either<Failure, void>> call(String id) {
    return _repository.deleteContent(id);
  }
}
