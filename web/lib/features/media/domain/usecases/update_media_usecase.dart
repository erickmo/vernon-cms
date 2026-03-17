import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/media_file.dart';
import '../repositories/media_repository.dart';

/// Use case untuk memperbarui metadata file media.
class UpdateMediaUseCase {
  final MediaRepository _repository;

  const UpdateMediaUseCase(this._repository);

  /// Returns [Right(MediaFile)] jika berhasil.
  Future<Either<Failure, MediaFile>> call(
    String id,
    Map<String, dynamic> data,
  ) {
    return _repository.updateMedia(id, data);
  }
}
