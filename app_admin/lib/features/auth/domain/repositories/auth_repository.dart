import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/login_params.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> login(LoginParams params);
  Future<Either<Failure, void>> logout();
}
