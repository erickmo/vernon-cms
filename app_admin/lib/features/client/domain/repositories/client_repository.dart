import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/client.dart';
import '../entities/client_params.dart';

abstract class ClientRepository {
  Future<Either<Failure, List<Client>>> getClients({String? search, bool? isActive});
  Future<Either<Failure, Client>> getClient(String id);
  Future<Either<Failure, Client>> createClient(CreateClientParams params);
  Future<Either<Failure, Client>> updateClient(UpdateClientParams params);
  Future<Either<Failure, void>> deleteClient(String id);
  Future<Either<Failure, void>> toggleActive(String id);
}
