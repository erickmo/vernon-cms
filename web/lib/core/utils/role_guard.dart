/// Helper functions untuk Role-Based Access Control (RBAC).
///
/// Roles: admin, editor, viewer
/// - Admin: full akses semua fitur
/// - Editor: bisa buat dan edit page, category, content. Tidak bisa delete atau manage user
/// - Viewer: hanya bisa lihat data (read-only)
class RoleGuard {
  RoleGuard._();

  static const String admin = 'admin';
  static const String editor = 'editor';
  static const String viewer = 'viewer';

  /// Apakah role bisa membuat resource (POST) — page, category, content.
  static bool canCreate(String? role) {
    return role == admin || role == editor;
  }

  /// Apakah role bisa mengedit resource (PUT) — page, category, content.
  static bool canEdit(String? role) {
    return role == admin || role == editor;
  }

  /// Apakah role bisa menghapus resource (DELETE).
  static bool canDelete(String? role) {
    return role == admin;
  }

  /// Apakah role bisa mengelola user (CRUD users).
  static bool canManageUsers(String? role) {
    return role == admin;
  }

  /// Apakah role bisa mengakses settings.
  static bool canAccessSettings(String? role) {
    return role == admin;
  }

  /// Apakah role bisa publish content.
  static bool canPublish(String? role) {
    return role == admin || role == editor;
  }

  /// Mengembalikan display name untuk role.
  static String displayName(String? role) {
    switch (role) {
      case admin:
        return 'Admin';
      case editor:
        return 'Editor';
      case viewer:
        return 'Viewer';
      default:
        return 'Unknown';
    }
  }
}
