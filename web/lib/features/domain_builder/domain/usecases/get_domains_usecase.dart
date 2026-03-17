import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/domain_definition.dart';
import '../repositories/domain_builder_repository.dart';

/// Use case untuk mengambil daftar semua domain.
class GetDomainsUseCase {
  final DomainBuilderRepository _repository;

  const GetDomainsUseCase(this._repository);

  /// Returns [Right(List<DomainDefinition>)] jika berhasil.
  Future<Either<Failure, List<DomainDefinition>>> call() {
    return _repository.getDomains();
  }
}
