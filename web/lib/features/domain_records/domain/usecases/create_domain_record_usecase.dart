import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/domain_record.dart';
import '../repositories/domain_records_repository.dart';

/// Use case untuk membuat record domain baru.
class CreateDomainRecordUseCase {
  final DomainRecordsRepository _repository;

  const CreateDomainRecordUseCase(this._repository);

  /// Returns [Right(DomainRecord)] jika berhasil.
  Future<Either<Failure, DomainRecord>> call({
    required String domainSlug,
    required Map<String, dynamic> data,
  }) {
    return _repository.createRecord(
      domainSlug: domainSlug,
      data: data,
    );
  }
}
