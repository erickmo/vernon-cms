import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/record_option.dart';
import '../repositories/domain_records_repository.dart';

/// Use case untuk mengambil daftar opsi record (relation dropdown).
class GetRecordOptionsUseCase {
  final DomainRecordsRepository _repository;

  const GetRecordOptionsUseCase(this._repository);

  /// Returns [Right(List<RecordOption>)] jika berhasil.
  Future<Either<Failure, List<RecordOption>>> call({
    required String domainSlug,
  }) {
    return _repository.getRecordOptions(
      domainSlug: domainSlug,
    );
  }
}
