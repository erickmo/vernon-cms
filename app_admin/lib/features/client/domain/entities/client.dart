import 'package:equatable/equatable.dart';

class Client extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? company;
  final String? address;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Client({
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

  @override
  List<Object?> get props => [id, name, email, phone, company, address, isActive];
}
