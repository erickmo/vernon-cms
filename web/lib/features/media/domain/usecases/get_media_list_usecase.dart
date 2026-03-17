import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/media_file.dart';
import '../repositories/media_repository.dart';

/// Use case untuk mengambil daftar file media.
class GetMediaListUseCase {
  final MediaRepository _repository;

  const GetMediaListUseCase(this._repository);

  /// Returns [Right(List<MediaFile>)] jika berhasil.
  Future<Either<Failure, List<MediaFile>>> call({
    String? search,
    String? mimeType,
    String? folder,
    int page = 1,
    int perPage = 20,
  }) {
    return _repository.getMediaList(
      search: search,
      mimeType: mimeType,
      folder: folder,
      page: page,
      perPage: perPage,
    );
  }
}
