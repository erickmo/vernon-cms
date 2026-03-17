import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/content.dart';
import '../repositories/content_repository.dart';

/// Use case untuk mengambil daftar konten.
class GetContentsUseCase {
  final ContentRepository _repository;

  const GetContentsUseCase(this._repository);

  /// Returns [Right(List<Content>)] jika berhasil.
  Future<Either<Failure, List<Content>>> call({
    String? search,
    String? status,
    int page = 1,
    int limit = 20,
  }) {
    return _repository.getContents(
      search: search,
      status: status,
      page: page,
      limit: limit,
    );
  }
}
