import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../domain/entities/content_category.dart';
import '../../domain/repositories/content_category_repository.dart';
import '../datasources/content_category_remote_datasource.dart';

/// Implementasi [ContentCategoryRepository].
class ContentCategoryRepositoryImpl implements ContentCategoryRepository {
  final ContentCategoryRemoteDataSource _remoteDataSource;

  const ContentCategoryRepositoryImpl({
    required ContentCategoryRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<ContentCategory>>> getCategories({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _remoteDataSource.getCategories(
        page: page,
        limit: limit,
      );
      return Right(response.items.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, ContentCategory>> getCategoryById(String id) async {
    try {
      final response = await _remoteDataSource.getCategoryById(id);
      return Right(response.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, void>> createCategory(
    ContentCategory category,
  ) async {
    try {
      final data = <String, dynamic>{
        'name': category.name,
        'slug': category.slug,
      };

      await _remoteDataSource.createCategory(data);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, void>> updateCategory(
    ContentCategory category,
  ) async {
    try {
      final data = <String, dynamic>{
        'name': category.name,
        'slug': category.slug,
      };

      await _remoteDataSource.updateCategory(category.id, data);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      await _remoteDataSource.deleteCategory(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }
}
