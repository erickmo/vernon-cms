import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/payment.dart';
import '../repositories/payment_repository.dart';

class GetPaymentsUseCase {
  final PaymentRepository _repository;
  const GetPaymentsUseCase(this._repository);

  Future<Either<Failure, List<Payment>>> call({
    String? clientId,
    PaymentStatus? status,
  }) =>
      _repository.getPayments(clientId: clientId, status: status);
}
