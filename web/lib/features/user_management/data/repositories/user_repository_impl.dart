import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../domain/entities/cms_user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';

/// Implementasi [UserRepository].
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remoteDataSource;

  const UserRepositoryImpl({
    required UserRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<CmsUser>>> getUsers({
    String? search,
    String? role,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _remoteDataSource.getUsers(
        search: search,
        role: role,
        page: page,
        limit: limit,
      );
      return Right(response.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, CmsUser>> getUserById(String id) async {
    try {
      final response = await _remoteDataSource.getUserById(id);
      return Right(response.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, void>> createUser(
    CmsUser user, {
    required String passwordHash,
  }) async {
    try {
      final data = <String, dynamic>{
        'email': user.email,
        'password_hash': passwordHash,
        'name': user.name,
        'role': user.role,
      };

      await _remoteDataSource.createUser(data);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, void>> updateUser(CmsUser user) async {
    try {
      final data = <String, dynamic>{
        'email': user.email,
        'name': user.name,
        'role': user.role,
      };

      await _remoteDataSource.updateUser(user.id, data);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(String id) async {
    try {
      await _remoteDataSource.deleteUser(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }
}
