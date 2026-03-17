import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../domain/entities/domain_definition.dart';
import '../../domain/repositories/domain_builder_repository.dart';
import '../datasources/domain_builder_remote_datasource.dart';
import '../models/domain_definition_model.dart';

/// Implementasi [DomainBuilderRepository].
class DomainBuilderRepositoryImpl implements DomainBuilderRepository {
  final DomainBuilderRemoteDataSource _remoteDataSource;

  const DomainBuilderRepositoryImpl({
    required DomainBuilderRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<DomainDefinition>>> getDomains() async {
    try {
      final response = await _remoteDataSource.getDomains();
      return Right(response.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, DomainDefinition>> getDomainDetail(String id) async {
    try {
      final response = await _remoteDataSource.getDomainDetail(id);
      return Right(response.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, DomainDefinition>> createDomain(
    DomainDefinition domain,
  ) async {
    try {
      final model = DomainDefinitionModel.fromEntity(domain);
      final data = model.toJson();
      // Hapus field read-only yang tidak perlu dikirim ke server.
      data.remove('id');
      data.remove('created_at');
      data.remove('updated_at');

      final response = await _remoteDataSource.createDomain(data);
      return Right(response.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, DomainDefinition>> updateDomain(
    DomainDefinition domain,
  ) async {
    try {
      final model = DomainDefinitionModel.fromEntity(domain);
      final data = model.toJson();
      // Hapus field read-only yang tidak perlu dikirim ke server.
      data.remove('id');
      data.remove('created_at');
      data.remove('updated_at');

      final response = await _remoteDataSource.updateDomain(
        domain.id,
        data,
      );
      return Right(response.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDomain(String id) async {
    try {
      await _remoteDataSource.deleteDomain(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }
}
