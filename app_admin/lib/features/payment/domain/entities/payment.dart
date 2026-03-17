import 'package:equatable/equatable.dart';

enum PaymentStatus { pending, paid, failed, cancelled }

class Payment extends Equatable {
  final String id;
  final String clientId;
  final String clientName;
  final double amount;
  final PaymentStatus status;
  final String? description;
  final String? method;
  final DateTime? dueDate;
  final DateTime? paidAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Payment({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.amount,
    required this.status,
    this.description,
    this.method,
    this.dueDate,
    this.paidAt,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props =>
      [id, clientId, amount, status, description, method, dueDate, paidAt];
}
