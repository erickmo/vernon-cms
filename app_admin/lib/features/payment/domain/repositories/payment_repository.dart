import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/payment.dart';
import '../entities/payment_params.dart';

abstract class PaymentRepository {
  Future<Either<Failure, List<Payment>>> getPayments({
    String? clientId,
    PaymentStatus? status,
  });
  Future<Either<Failure, Payment>> getPayment(String id);
  Future<Either<Failure, Payment>> createPayment(CreatePaymentParams params);
}
