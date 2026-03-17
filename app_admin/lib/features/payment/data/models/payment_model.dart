import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/payment.dart';

part 'payment_model.g.dart';

@JsonSerializable()
class PaymentModel {
  final String id;
  @JsonKey(name: 'client_id')
  final String clientId;
  @JsonKey(name: 'client_name')
  final String clientName;
  final double amount;
  final String status;
  final String? description;
  final String? method;
  @JsonKey(name: 'due_date')
  final DateTime? dueDate;
  @JsonKey(name: 'paid_at')
  final DateTime? paidAt;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const PaymentModel({
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

  factory PaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentModelToJson(this);

  Payment toEntity() => Payment(
        id: id,
        clientId: clientId,
        clientName: clientName,
        amount: amount,
        status: _parseStatus(status),
        description: description,
        method: method,
        dueDate: dueDate,
        paidAt: paidAt,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  static PaymentStatus _parseStatus(String s) {
    switch (s) {
      case 'paid':
        return PaymentStatus.paid;
      case 'failed':
        return PaymentStatus.failed;
      case 'cancelled':
        return PaymentStatus.cancelled;
      default:
        return PaymentStatus.pending;
    }
  }
}
