import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../domain/entities/media_file.dart';
import '../../domain/repositories/media_repository.dart';
import '../datasources/media_remote_datasource.dart';

/// Implementasi [MediaRepository].
class MediaRepositoryImpl implements MediaRepository {
  final MediaRemoteDataSource _remoteDataSource;

  const MediaRepositoryImpl({
    required MediaRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<MediaFile>>> getMediaList({
    String? search,
    String? mimeType,
    String? folder,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _remoteDataSource.getMediaList(
        search: search,
        mimeType: mimeType,
        folder: folder,
        page: page,
        perPage: perPage,
      );
      return Right(response.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, MediaFile>> getMediaDetail(String id) async {
    try {
      final response = await _remoteDataSource.getMediaDetail(id);
      return Right(response.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, MediaFile>> uploadMedia(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _remoteDataSource.uploadMedia(data);
      return Right(response.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, MediaFile>> updateMedia(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _remoteDataSource.updateMedia(id, data);
      return Right(response.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMedia(String id) async {
    try {
      await _remoteDataSource.deleteMedia(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getMediaFolders() async {
    try {
      final response = await _remoteDataSource.getMediaFolders();
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }
}
