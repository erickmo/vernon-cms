import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/domain_record.dart';
import '../entities/record_option.dart';

/// Interface repository untuk domain records.
abstract class DomainRecordsRepository {
  /// Ambil daftar record untuk domain tertentu.
  Future<Either<Failure, List<DomainRecord>>> getRecords({
    required String domainSlug,
    String? search,
    int page = 1,
    int perPage = 10,
  });

  /// Ambil detail record berdasarkan [id].
  Future<Either<Failure, DomainRecord>> getRecordDetail({
    required String domainSlug,
    required String id,
  });

  /// Buat record baru.
  Future<Either<Failure, DomainRecord>> createRecord({
    required String domainSlug,
    required Map<String, dynamic> data,
  });

  /// Perbarui record yang sudah ada.
  Future<Either<Failure, DomainRecord>> updateRecord({
    required String domainSlug,
    required String id,
    required Map<String, dynamic> data,
  });

  /// Hapus record berdasarkan [id].
  Future<Either<Failure, void>> deleteRecord({
    required String domainSlug,
    required String id,
  });

  /// Ambil daftar opsi record untuk relation dropdown.
  Future<Either<Failure, List<RecordOption>>> getRecordOptions({
    required String domainSlug,
  });
}
