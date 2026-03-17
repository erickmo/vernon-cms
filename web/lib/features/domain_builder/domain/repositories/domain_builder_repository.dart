import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/domain_definition.dart';

/// Interface repository untuk domain builder.
abstract class DomainBuilderRepository {
  /// Ambil daftar semua domain.
  Future<Either<Failure, List<DomainDefinition>>> getDomains();

  /// Ambil detail domain berdasarkan [id].
  Future<Either<Failure, DomainDefinition>> getDomainDetail(String id);

  /// Buat domain baru.
  Future<Either<Failure, DomainDefinition>> createDomain(
    DomainDefinition domain,
  );

  /// Perbarui domain yang sudah ada.
  Future<Either<Failure, DomainDefinition>> updateDomain(
    DomainDefinition domain,
  );

  /// Hapus domain berdasarkan [id].
  Future<Either<Failure, void>> deleteDomain(String id);
}
