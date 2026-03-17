import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/client.dart';
import '../repositories/client_repository.dart';

class GetClientUseCase {
  final ClientRepository _repository;
  const GetClientUseCase(this._repository);

  Future<Either<Failure, Client>> call(String id) => _repository.getClient(id);
}
