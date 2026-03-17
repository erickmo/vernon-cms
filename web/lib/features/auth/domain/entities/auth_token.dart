import 'package:equatable/equatable.dart';

/// Entity token autentikasi.
class AuthToken extends Equatable {
  /// JWT access token.
  final String accessToken;

  /// JWT refresh token.
  final String refreshToken;

  /// Waktu expired token sebagai unix timestamp (detik).
  final int expiresAt;

  const AuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  @override
  List<Object> get props => [accessToken, refreshToken, expiresAt];
}
