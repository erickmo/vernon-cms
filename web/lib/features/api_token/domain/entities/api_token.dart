import 'package:equatable/equatable.dart';

/// Entity API token.
class ApiToken extends Equatable {
  /// ID unik token.
  final String id;

  /// Nama deskriptif token.
  final String name;

  /// Token aktual (hanya tersedia saat pembuatan).
  final String token;

  /// Prefix token untuk identifikasi (8 karakter pertama).
  final String prefix;

  /// Daftar permission.
  final List<String> permissions;

  /// Tanggal kedaluwarsa (opsional).
  final DateTime? expiresAt;

  /// Tanggal terakhir digunakan (opsional).
  final DateTime? lastUsedAt;

  /// Apakah token aktif.
  final bool isActive;

  /// Tanggal dibuat.
  final DateTime createdAt;

  const ApiToken({
    required this.id,
    required this.name,
    this.token = '',
    required this.prefix,
    this.permissions = const [],
    this.expiresAt,
    this.lastUsedAt,
    this.isActive = true,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        token,
        prefix,
        permissions,
        expiresAt,
        lastUsedAt,
        isActive,
        createdAt,
      ];
}
