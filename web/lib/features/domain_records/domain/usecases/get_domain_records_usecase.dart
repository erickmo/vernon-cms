import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/domain_record.dart';
import '../repositories/domain_records_repository.dart';

/// Use case untuk mengambil daftar record domain.
class GetDomainRecordsUseCase {
  final DomainRecordsRepository _repository;

  const GetDomainRecordsUseCase(this._repository);

  /// Returns [Right(List<DomainRecord>)] jika berhasil.
  Future<Either<Failure, List<DomainRecord>>> call({
    required String domainSlug,
    String? search,
    int page = 1,
    int perPage = 10,
  }) {
    return _repository.getRecords(
      domainSlug: domainSlug,
      search: search,
      page: page,
      perPage: perPage,
    );
  }
}
