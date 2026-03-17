import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/payment_params.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_datasource.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource _remoteDataSource;
  const PaymentRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Payment>>> getPayments({
    String? clientId,
    PaymentStatus? status,
  }) async {
    try {
      final models = await _remoteDataSource.getPayments(
        clientId: clientId,
        status: status,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(
        e.message ?? 'Gagal memuat payments',
        statusCode: e.response?.statusCode,
      ));
    }
  }

  @override
  Future<Either<Failure, Payment>> getPayment(String id) async {
    try {
      final model = await _remoteDataSource.getPayment(id);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(
        e.message ?? 'Gagal memuat payment',
        statusCode: e.response?.statusCode,
      ));
    }
  }

  @override
  Future<Either<Failure, Payment>> createPayment(
      CreatePaymentParams params) async {
    try {
      final model = await _remoteDataSource.createPayment(params);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(
        e.message ?? 'Gagal membuat payment',
        statusCode: e.response?.statusCode,
      ));
    }
  }
}
