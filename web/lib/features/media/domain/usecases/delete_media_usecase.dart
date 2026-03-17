import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/media_repository.dart';

/// Use case untuk menghapus file media.
class DeleteMediaUseCase {
  final MediaRepository _repository;

  const DeleteMediaUseCase(this._repository);

  /// Returns [Right(void)] jika berhasil.
  Future<Either<Failure, void>> call(String id) {
    return _repository.deleteMedia(id);
  }
}
