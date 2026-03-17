import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/media_file.dart';
import '../repositories/media_repository.dart';

/// Use case untuk mengunggah file media baru.
class UploadMediaUseCase {
  final MediaRepository _repository;

  const UploadMediaUseCase(this._repository);

  /// Returns [Right(MediaFile)] jika berhasil.
  Future<Either<Failure, MediaFile>> call(Map<String, dynamic> data) {
    return _repository.uploadMedia(data);
  }
}
