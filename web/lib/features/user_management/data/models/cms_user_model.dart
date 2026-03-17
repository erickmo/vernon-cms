import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/cms_user.dart';

part 'cms_user_model.g.dart';

/// Model response user dari API.
///
/// API response di-wrap dalam `{ "data": { ... } }`.
/// List response: `{ "data": { "items": [...], "total", "page", "limit" } }`.
@JsonSerializable()
class CmsUserModel {
  /// ID unik user.
  final String id;

  /// Alamat email.
  final String email;

  /// Nama user.
  final String name;

  /// Role user (admin, editor, viewer).
  final String role;

  /// Apakah user aktif.
  @JsonKey(name: 'is_active')
  final bool isActive;

  /// Tanggal dibuat.
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// Tanggal terakhir diperbarui.
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const CmsUserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Parse dari JSON.
  factory CmsUserModel.fromJson(Map<String, dynamic> json) =>
      _$CmsUserModelFromJson(json);

  /// Convert ke JSON.
  Map<String, dynamic> toJson() => _$CmsUserModelToJson(this);

  /// Convert ke domain entity.
  CmsUser toEntity() => CmsUser(
        id: id,
        email: email,
        name: name,
        role: role,
        isActive: isActive,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  /// Buat model dari domain entity.
  factory CmsUserModel.fromEntity(CmsUser entity) {
    return CmsUserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      role: entity.role,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
