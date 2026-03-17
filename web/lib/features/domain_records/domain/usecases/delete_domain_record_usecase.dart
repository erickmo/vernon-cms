import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/domain_records_repository.dart';

/// Use case untuk menghapus record domain.
class DeleteDomainRecordUseCase {
  final DomainRecordsRepository _repository;

  const DeleteDomainRecordUseCase(this._repository);

  /// Returns [Right(void)] jika berhasil.
  Future<Either<Failure, void>> call({
    required String domainSlug,
    required String id,
  }) {
    return _repository.deleteRecord(
      domainSlug: domainSlug,
      id: id,
    );
  }
}
