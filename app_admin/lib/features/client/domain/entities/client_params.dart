import 'package:equatable/equatable.dart';

class CreateClientParams extends Equatable {
  final String name;
  final String email;
  final String? phone;
  final String? company;
  final String? address;

  const CreateClientParams({
    required this.name,
    required this.email,
    this.phone,
    this.company,
    this.address,
  });

  @override
  List<Object?> get props => [name, email, phone, company, address];
}

class UpdateClientParams extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? company;
  final String? address;

  const UpdateClientParams({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.company,
    this.address,
  });

  @override
  List<Object?> get props => [id, name, email, phone, company, address];
}
