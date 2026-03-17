import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/media_file.dart';
import '../repositories/media_repository.dart';

/// Use case untuk mengambil detail file media.
class GetMediaDetailUseCase {
  final MediaRepository _repository;

  const GetMediaDetailUseCase(this._repository);

  /// Returns [Right(MediaFile)] jika berhasil.
  Future<Either<Failure, MediaFile>> call(String id) {
    return _repository.getMediaDetail(id);
  }
}
