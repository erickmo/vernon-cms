import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/api_token.dart';

part 'api_token_model.g.dart';

/// Model response API token dari API.
@JsonSerializable()
class ApiTokenModel {
  /// ID unik token.
  final String id;

  /// Nama deskriptif token.
  final String name;

  /// Token aktual (hanya saat pembuatan).
  @JsonKey(defaultValue: '')
  final String token;

  /// Prefix token untuk identifikasi.
  final String prefix;

  /// Daftar permission.
  @JsonKey(defaultValue: [])
  final List<String> permissions;

  /// Tanggal kedaluwarsa.
  @JsonKey(name: 'expires_at')
  final DateTime? expiresAt;

  /// Tanggal terakhir digunakan.
  @JsonKey(name: 'last_used_at')
  final DateTime? lastUsedAt;

  /// Apakah token aktif.
  @JsonKey(name: 'is_active')
  final bool isActive;

  /// Tanggal dibuat.
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const ApiTokenModel({
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

  /// Parse dari JSON.
  factory ApiTokenModel.fromJson(Map<String, dynamic> json) =>
      _$ApiTokenModelFromJson(json);

  /// Convert ke JSON.
  Map<String, dynamic> toJson() => _$ApiTokenModelToJson(this);

  /// Convert ke domain entity.
  ApiToken toEntity() => ApiToken(
        id: id,
        name: name,
        token: token,
        prefix: prefix,
        permissions: permissions,
        expiresAt: expiresAt,
        lastUsedAt: lastUsedAt,
        isActive: isActive,
        createdAt: createdAt,
      );

  /// Buat model dari domain entity.
  factory ApiTokenModel.fromEntity(ApiToken entity) {
    return ApiTokenModel(
      id: entity.id,
      name: entity.name,
      token: entity.token,
      prefix: entity.prefix,
      permissions: entity.permissions,
      expiresAt: entity.expiresAt,
      lastUsedAt: entity.lastUsedAt,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
    );
  }
}
