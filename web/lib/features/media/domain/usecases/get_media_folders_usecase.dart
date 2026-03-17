import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/media_repository.dart';

/// Use case untuk mengambil daftar folder media.
class GetMediaFoldersUseCase {
  final MediaRepository _repository;

  const GetMediaFoldersUseCase(this._repository);

  /// Returns [Right(List<String>)] jika berhasil.
  Future<Either<Failure, List<String>>> call() {
    return _repository.getMediaFolders();
  }
}
