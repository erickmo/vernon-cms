import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../domain/entities/api_token.dart';
import '../../domain/repositories/api_token_repository.dart';
import '../datasources/api_token_remote_datasource.dart';
import '../models/api_token_model.dart';

/// Implementasi [ApiTokenRepository].
class ApiTokenRepositoryImpl implements ApiTokenRepository {
  final ApiTokenRemoteDataSource _remoteDataSource;

  const ApiTokenRepositoryImpl({
    required ApiTokenRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<ApiToken>>> getTokens() async {
    try {
      final response = await _remoteDataSource.getTokens();
      return Right(response.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, ApiToken>> createToken(ApiToken token) async {
    try {
      final model = ApiTokenModel.fromEntity(token);
      final data = model.toJson();
      // Hapus field read-only yang tidak perlu dikirim ke server.
      data.remove('id');
      data.remove('token');
      data.remove('prefix');
      data.remove('last_used_at');
      data.remove('created_at');

      final response = await _remoteDataSource.createToken(data);
      return Right(response.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, ApiToken>> updateToken(ApiToken token) async {
    try {
      final data = <String, dynamic>{
        'name': token.name,
        'permissions': token.permissions,
        'is_active': token.isActive,
      };

      final response = await _remoteDataSource.updateToken(token.id, data);
      return Right(response.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, void>> deleteToken(String id) async {
    try {
      await _remoteDataSource.deleteToken(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, ApiToken>> toggleTokenActive(String id) async {
    try {
      final response = await _remoteDataSource.toggleTokenActive(id);
      return Right(response.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }
}
