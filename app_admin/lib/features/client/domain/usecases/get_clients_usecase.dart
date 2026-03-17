import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/client.dart';
import '../repositories/client_repository.dart';

class GetClientsUseCase {
  final ClientRepository _repository;
  const GetClientsUseCase(this._repository);

  Future<Either<Failure, List<Client>>> call({String? search, bool? isActive}) =>
      _repository.getClients(search: search, isActive: isActive);
}
