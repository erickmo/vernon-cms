import 'package:equatable/equatable.dart';

/// Parameter untuk login.
class LoginParams extends Equatable {
  /// Email untuk login.
  final String email;

  /// Password untuk login.
  final String password;

  /// Apakah user memilih remember me.
  final bool rememberMe;

  const LoginParams({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object> get props => [email, password, rememberMe];
}
