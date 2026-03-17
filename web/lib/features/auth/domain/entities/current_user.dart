import 'package:equatable/equatable.dart';

/// Entity untuk user yang sedang login.
///
/// Data diambil dari decode JWT access token payload.
class CurrentUser extends Equatable {
  /// User ID (UUID).
  final String id;

  /// Email user.
  final String email;

  /// Role user: admin, editor, atau viewer.
  final String role;

  const CurrentUser({
    required this.id,
    required this.email,
    required this.role,
  });

  @override
  List<Object> get props => [id, email, role];
}
