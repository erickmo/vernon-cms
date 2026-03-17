import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/domain_definition.dart';
import '../repositories/domain_builder_repository.dart';

/// Use case untuk mengambil detail domain.
class GetDomainDetailUseCase {
  final DomainBuilderRepository _repository;

  const GetDomainDetailUseCase(this._repository);

  /// Returns [Right(DomainDefinition)] jika berhasil.
  Future<Either<Failure, DomainDefinition>> call(String id) {
    return _repository.getDomainDetail(id);
  }
}
