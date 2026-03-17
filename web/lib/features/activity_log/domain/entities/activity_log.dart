import 'package:equatable/equatable.dart';

/// Entity log aktivitas.
class ActivityLog extends Equatable {
  /// ID unik log.
  final String id;

  /// Aksi yang dilakukan (created, updated, deleted, login, logout, published, archived).
  final String action;

  /// Tipe entitas (content, page, category, domain, user, settings, media).
  final String entityType;

  /// ID entitas terkait (opsional).
  final String? entityId;

  /// Judul entitas untuk display (opsional).
  final String? entityTitle;

  /// ID user yang melakukan aksi.
  final String userId;

  /// Nama user yang melakukan aksi.
  final String userName;

  /// URL avatar user (opsional).
  final String? userAvatarUrl;

  /// Detail perubahan (opsional).
  final String? details;

  /// Alamat IP (opsional).
  final String? ipAddress;

  /// Tanggal dibuat.
  final DateTime createdAt;

  const ActivityLog({
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

  @override
  List<Object?> get props => [
        id,
        action,
        entityType,
        entityId,
        entityTitle,
        userId,
        userName,
        userAvatarUrl,
        details,
        ipAddress,
        createdAt,
      ];
}
