import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/login_params.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;
  const LoginUseCase(this._repository);

  Future<Either<Failure, void>> call(LoginParams params) =>
      _repository.login(params);
}
