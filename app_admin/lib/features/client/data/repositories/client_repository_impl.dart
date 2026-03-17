import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/client.dart';
import '../../domain/entities/client_params.dart';
import '../../domain/repositories/client_repository.dart';
import '../datasources/client_remote_datasource.dart';

class ClientRepositoryImpl implements ClientRepository {
  final ClientRemoteDataSource _remoteDataSource;
  const ClientRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Client>>> getClients({
    String? search,
    bool? isActive,
  }) async {
    try {
      final models = await _remoteDataSource.getClients(
        search: search,
        isActive: isActive,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(
        e.message ?? 'Gagal memuat clients',
        statusCode: e.response?.statusCode,
      ));
    }
  }

  @override
  Future<Either<Failure, Client>> getClient(String id) async {
    try {
      final model = await _remoteDataSource.getClient(id);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(
        e.message ?? 'Gagal memuat client',
        statusCode: e.response?.statusCode,
      ));
    }
  }

  @override
  Future<Either<Failure, Client>> createClient(
      CreateClientParams params) async {
    try {
      final model = await _remoteDataSource.createClient(params);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(
        e.message ?? 'Gagal membuat client',
        statusCode: e.response?.statusCode,
      ));
    }
  }

  @override
  Future<Either<Failure, Client>> updateClient(
      UpdateClientParams params) async {
    try {
      final model = await _remoteDataSource.updateClient(params);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(
        e.message ?? 'Gagal memperbarui client',
        statusCode: e.response?.statusCode,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteClient(String id) async {
    try {
      await _remoteDataSource.deleteClient(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(
        e.message ?? 'Gagal menghapus client',
        statusCode: e.response?.statusCode,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> toggleActive(String id) async {
    try {
      await _remoteDataSource.toggleActive(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(
        e.message ?? 'Gagal mengubah status client',
        statusCode: e.response?.statusCode,
      ));
    }
  }
}
