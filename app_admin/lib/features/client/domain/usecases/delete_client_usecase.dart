import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/client_repository.dart';

class DeleteClientUseCase {
  final ClientRepository _repository;
  const DeleteClientUseCase(this._repository);

  Future<Either<Failure, void>> call(String id) => _repository.deleteClient(id);
}
