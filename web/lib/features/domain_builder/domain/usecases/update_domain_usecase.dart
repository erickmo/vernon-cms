import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/domain_definition.dart';
import '../repositories/domain_builder_repository.dart';

/// Use case untuk memperbarui domain.
class UpdateDomainUseCase {
  final DomainBuilderRepository _repository;

  const UpdateDomainUseCase(this._repository);

  /// Returns [Right(DomainDefinition)] jika berhasil.
  Future<Either<Failure, DomainDefinition>> call(DomainDefinition domain) {
    return _repository.updateDomain(domain);
  }
}
