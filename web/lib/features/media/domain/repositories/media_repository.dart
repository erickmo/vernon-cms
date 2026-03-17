import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/media_file.dart';

/// Interface repository untuk media.
abstract class MediaRepository {
  /// Ambil daftar file media.
  Future<Either<Failure, List<MediaFile>>> getMediaList({
    String? search,
    String? mimeType,
    String? folder,
    int page = 1,
    int perPage = 20,
  });

  /// Ambil detail file media berdasarkan [id].
  Future<Either<Failure, MediaFile>> getMediaDetail(String id);

  /// Upload file media baru.
  Future<Either<Failure, MediaFile>> uploadMedia(Map<String, dynamic> data);

  /// Update metadata file media.
  Future<Either<Failure, MediaFile>> updateMedia(
    String id,
    Map<String, dynamic> data,
  );

  /// Hapus file media berdasarkan [id].
  Future<Either<Failure, void>> deleteMedia(String id);

  /// Ambil daftar folder unik.
  Future<Either<Failure, List<String>>> getMediaFolders();
}
