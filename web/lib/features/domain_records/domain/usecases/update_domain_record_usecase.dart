import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/domain_record.dart';
import '../repositories/domain_records_repository.dart';

/// Use case untuk memperbarui record domain.
class UpdateDomainRecordUseCase {
  final DomainRecordsRepository _repository;

  const UpdateDomainRecordUseCase(this._repository);

  /// Returns [Right(DomainRecord)] jika berhasil.
  Future<Either<Failure, DomainRecord>> call({
    required String domainSlug,
    required String id,
    required Map<String, dynamic> data,
  }) {
    return _repository.updateRecord(
      domainSlug: domainSlug,
      id: id,
      data: data,
    );
  }
}
