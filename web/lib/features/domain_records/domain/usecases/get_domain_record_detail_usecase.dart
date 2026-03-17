import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/domain_record.dart';
import '../repositories/domain_records_repository.dart';

/// Use case untuk mengambil detail record domain.
class GetDomainRecordDetailUseCase {
  final DomainRecordsRepository _repository;

  const GetDomainRecordDetailUseCase(this._repository);

  /// Returns [Right(DomainRecord)] jika berhasil.
  Future<Either<Failure, DomainRecord>> call({
    required String domainSlug,
    required String id,
  }) {
    return _repository.getRecordDetail(
      domainSlug: domainSlug,
      id: id,
    );
  }
}
