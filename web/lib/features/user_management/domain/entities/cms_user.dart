import 'package:equatable/equatable.dart';

/// Entity user CMS.
///
/// Sesuai API spec: id, email, name, role, is_active, created_at, updated_at.
/// Role: admin, editor, viewer.
class CmsUser extends Equatable {
  /// ID unik user.
  final String id;

  /// Alamat email.
  final String email;

  /// Nama user.
  final String name;

  /// Role user (admin, editor, viewer).
  final String role;

  /// Apakah user aktif.
  final bool isActive;

  /// Tanggal dibuat.
  final DateTime createdAt;

  /// Tanggal terakhir diperbarui.
  final DateTime updatedAt;

  const CmsUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        role,
        isActive,
        createdAt,
        updatedAt,
      ];
}
