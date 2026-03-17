import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/content_repository.dart';

/// Use case untuk mempublikasikan konten (draft -> published).
class PublishContentUseCase {
  final ContentRepository _repository;

  const PublishContentUseCase(this._repository);

  /// Returns [Right(void)] jika berhasil.
  Future<Either<Failure, void>> call(String id) {
    return _repository.publishContent(id);
  }
}
