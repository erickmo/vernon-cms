import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/payment.dart';
import '../repositories/payment_repository.dart';

class GetPaymentUseCase {
  final PaymentRepository _repository;
  const GetPaymentUseCase(this._repository);

  Future<Either<Failure, Payment>> call(String id) =>
      _repository.getPayment(id);
}
