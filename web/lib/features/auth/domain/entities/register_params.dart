import 'package:equatable/equatable.dart';

/// Parameter untuk register user baru.
class RegisterParams extends Equatable {
  /// Email user.
  final String email;

  /// Password user (minimal 8 karakter).
  final String password;

  /// Nama lengkap user.
  final String name;

  const RegisterParams({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object> get props => [email, password, name];
}
