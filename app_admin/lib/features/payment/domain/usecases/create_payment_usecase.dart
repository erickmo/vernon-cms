import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/payment.dart';
import '../entities/payment_params.dart';
import '../repositories/payment_repository.dart';

class CreatePaymentUseCase {
  final PaymentRepository _repository;
  const CreatePaymentUseCase(this._repository);

  Future<Either<Failure, Payment>> call(CreatePaymentParams params) =>
      _repository.createPayment(params);
}
