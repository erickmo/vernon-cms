import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../domain/entities/domain_record.dart';
import '../../domain/entities/record_option.dart';
import '../../domain/repositories/domain_records_repository.dart';
import '../datasources/domain_records_remote_datasource.dart';

/// Implementasi [DomainRecordsRepository].
class DomainRecordsRepositoryImpl implements DomainRecordsRepository {
  final DomainRecordsRemoteDataSource _remoteDataSource;

  const DomainRecordsRepositoryImpl({
    required DomainRecordsRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<DomainRecord>>> getRecords({
    required String domainSlug,
    String? search,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await _remoteDataSource.getRecords(
        domainSlug: domainSlug,
        search: search,
        page: page,
        perPage: perPage,
      );
      return Right(response.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, DomainRecord>> getRecordDetail({
    required String domainSlug,
    required String id,
  }) async {
    try {
      final response = await _remoteDataSource.getRecordDetail(
        domainSlug: domainSlug,
        id: id,
      );
      return Right(response.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, DomainRecord>> createRecord({
    required String domainSlug,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _remoteDataSource.createRecord(
        domainSlug: domainSlug,
        data: data,
      );
      return Right(response.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, DomainRecord>> updateRecord({
    required String domainSlug,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _remoteDataSource.updateRecord(
        domainSlug: domainSlug,
        id: id,
        data: data,
      );
      return Right(response.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRecord({
    required String domainSlug,
    required String id,
  }) async {
    try {
      await _remoteDataSource.deleteRecord(
        domainSlug: domainSlug,
        id: id,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, List<RecordOption>>> getRecordOptions({
    required String domainSlug,
  }) async {
    try {
      final response = await _remoteDataSource.getRecordOptions(
        domainSlug: domainSlug,
      );
      return Right(response.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }
}
