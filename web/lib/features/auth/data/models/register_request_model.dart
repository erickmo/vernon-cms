import 'package:json_annotation/json_annotation.dart';

part 'register_request_model.g.dart';

/// Model request untuk API register.
@JsonSerializable()
class RegisterRequestModel {
  /// Email user.
  final String email;

  /// Password user.
  final String password;

  /// Nama lengkap user.
  final String name;

  const RegisterRequestModel({
    required this.email,
    required this.password,
    required this.name,
  });

  /// Convert ke JSON map.
  Map<String, dynamic> toJson() => _$RegisterRequestModelToJson(this);
}
