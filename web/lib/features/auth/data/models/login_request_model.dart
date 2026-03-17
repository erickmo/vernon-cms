import 'package:json_annotation/json_annotation.dart';

part 'login_request_model.g.dart';

/// Model request untuk API login.
@JsonSerializable()
class LoginRequestModel {
  /// Email untuk login.
  final String email;

  /// Password untuk login.
  final String password;

  const LoginRequestModel({
    required this.email,
    required this.password,
  });

  /// Convert ke JSON map.
  Map<String, dynamic> toJson() => _$LoginRequestModelToJson(this);
}
