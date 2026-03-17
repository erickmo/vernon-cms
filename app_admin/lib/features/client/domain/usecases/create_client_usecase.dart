import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/client.dart';
import '../entities/client_params.dart';
import '../repositories/client_repository.dart';

class CreateClientUseCase {
  final ClientRepository _repository;
  const CreateClientUseCase(this._repository);

  Future<Either<Failure, Client>> call(CreateClientParams params) =>
      _repository.createClient(params);
}
