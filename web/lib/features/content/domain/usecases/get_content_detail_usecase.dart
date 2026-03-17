import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/content.dart';
import '../repositories/content_repository.dart';

/// Use case untuk mengambil detail konten.
class GetContentDetailUseCase {
  final ContentRepository _repository;

  const GetContentDetailUseCase(this._repository);

  /// Returns [Right(Content)] jika berhasil.
  Future<Either<Failure, Content>> call(String id) {
    return _repository.getContentById(id);
  }
}
