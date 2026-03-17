import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../domain/entities/content.dart';
import '../../domain/repositories/content_repository.dart';
import '../datasources/content_remote_datasource.dart';

/// Implementasi [ContentRepository].
class ContentRepositoryImpl implements ContentRepository {
  final ContentRemoteDataSource _remoteDataSource;

  const ContentRepositoryImpl({
    required ContentRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<Content>>> getContents({
    String? search,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _remoteDataSource.getContents(
        search: search,
        status: status,
        page: page,
        limit: limit,
      );
      return Right(response.items.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, Content>> getContentById(String id) async {
    try {
      final response = await _remoteDataSource.getContentById(id);
      return Right(response.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, void>> createContent(Content content) async {
    try {
      final data = <String, dynamic>{
        'title': content.title,
        'slug': content.slug,
        if (content.body != null) 'body': content.body,
        if (content.excerpt != null) 'excerpt': content.excerpt,
        if (content.pageId != null) 'page_id': content.pageId,
        if (content.categoryId != null) 'category_id': content.categoryId,
        if (content.authorId != null) 'author_id': content.authorId,
        if (content.metadata.isNotEmpty) 'metadata': content.metadata,
      };

      await _remoteDataSource.createContent(data);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, void>> updateContent(Content content) async {
    try {
      final data = <String, dynamic>{
        'title': content.title,
        'slug': content.slug,
        if (content.body != null) 'body': content.body,
        if (content.excerpt != null) 'excerpt': content.excerpt,
        if (content.metadata.isNotEmpty) 'metadata': content.metadata,
      };

      await _remoteDataSource.updateContent(content.id, data);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, void>> publishContent(String id) async {
    try {
      await _remoteDataSource.publishContent(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, void>> deleteContent(String id) async {
    try {
      await _remoteDataSource.deleteContent(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }
}
