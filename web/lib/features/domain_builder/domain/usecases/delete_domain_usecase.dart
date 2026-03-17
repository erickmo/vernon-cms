import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/domain_builder_repository.dart';

/// Use case untuk menghapus domain.
class DeleteDomainUseCase {
  final DomainBuilderRepository _repository;

  const DeleteDomainUseCase(this._repository);

  /// Returns [Right(void)] jika berhasil.
  Future<Either<Failure, void>> call(String id) {
    return _repository.deleteDomain(id);
  }
}
