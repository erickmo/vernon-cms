import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/activity_log.dart';

part 'activity_log_model.g.dart';

/// Model response log aktivitas dari API.
@JsonSerializable()
class ActivityLogModel {
  /// ID unik log.
  final String id;

  /// Aksi yang dilakukan.
  final String action;

  /// Tipe entitas.
  @JsonKey(name: 'entity_type')
  final String entityType;

  /// ID entitas terkait.
  @JsonKey(name: 'entity_id')
  final String? entityId;

  /// Judul entitas untuk display.
  @JsonKey(name: 'entity_title')
  final String? entityTitle;

  /// ID user yang melakukan aksi.
  @JsonKey(name: 'user_id')
  final String userId;

  /// Nama user yang melakukan aksi.
  @JsonKey(name: 'user_name')
  final String userName;

  /// URL avatar user.
  @JsonKey(name: 'user_avatar_url')
  final String? userAvatarUrl;

  /// Detail perubahan.
  final String? details;

  /// Alamat IP.
  @JsonKey(name: 'ip_address')
  final String? ipAddress;

  /// Tanggal dibuat.
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const ActivityLogModel({
    required this.id,
    required this.action,
    required this.entityType,
    this.entityId,
    this.entityTitle,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    this.details,
    this.ipAddress,
    required this.createdAt,
  });

  /// Parse dari JSON.
  factory ActivityLogModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityLogModelFromJson(json);

  /// Convert ke JSON.
  Map<String, dynamic> toJson() => _$ActivityLogModelToJson(this);

  /// Convert ke domain entity.
  ActivityLog toEntity() => ActivityLog(
        id: id,
        action: action,
        entityType: entityType,
        entityId: entityId,
        entityTitle: entityTitle,
        userId: userId,
        userName: userName,
        userAvatarUrl: userAvatarUrl,
        details: details,
        ipAddress: ipAddress,
        createdAt: createdAt,
      );
}
