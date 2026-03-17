import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../domain/entities/page_entity.dart';
import '../../domain/repositories/page_repository.dart';
import '../datasources/page_remote_datasource.dart';

/// Implementasi [PageRepository].
class PageRepositoryImpl implements PageRepository {
  final PageRemoteDataSource _remoteDataSource;

  const PageRepositoryImpl({
    required PageRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<PageEntity>>> getPages({
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _remoteDataSource.getPages(
        search: search,
        page: page,
        limit: limit,
      );
      return Right(response.items.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, PageEntity>> getPageById(String id) async {
    try {
      final response = await _remoteDataSource.getPageById(id);
      return Right(response.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, void>> createPage(PageEntity pageEntity) async {
    try {
      final data = <String, dynamic>{
        'name': pageEntity.name,
        'slug': pageEntity.slug,
        'variables': pageEntity.variables,
      };

      await _remoteDataSource.createPage(data);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, void>> updatePage(PageEntity pageEntity) async {
    try {
      final data = <String, dynamic>{
        'name': pageEntity.name,
        'slug': pageEntity.slug,
        'variables': pageEntity.variables,
        'is_active': pageEntity.isActive,
      };

      await _remoteDataSource.updatePage(pageEntity.id, data);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, void>> deletePage(String id) async {
    try {
      await _remoteDataSource.deletePage(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }
}
