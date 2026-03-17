import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/client.dart';

part 'client_model.g.dart';

@JsonSerializable()
class ClientModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? company;
  final String? address;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const ClientModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.company,
    this.address,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) =>
      _$ClientModelFromJson(json);

  Map<String, dynamic> toJson() => _$ClientModelToJson(this);

  Client toEntity() => Client(
        id: id,
        name: name,
        email: email,
        phone: phone,
        company: company,
        address: address,
        isActive: isActive,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
