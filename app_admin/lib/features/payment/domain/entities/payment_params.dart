import 'package:equatable/equatable.dart';

class CreatePaymentParams extends Equatable {
  final String clientId;
  final double amount;
  final String? description;
  final String? method;
  final DateTime? dueDate;

  const CreatePaymentParams({
    required this.clientId,
    required this.amount,
    this.description,
    this.method,
    this.dueDate,
  });

  @override
  List<Object?> get props => [clientId, amount, description, method, dueDate];
}
