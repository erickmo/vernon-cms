import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/client.dart';
import '../entities/client_params.dart';
import '../repositories/client_repository.dart';

class UpdateClientUseCase {
  final ClientRepository _repository;
  const UpdateClientUseCase(this._repository);

  Future<Either<Failure, Client>> call(UpdateClientParams params) =>
      _repository.updateClient(params);
}
