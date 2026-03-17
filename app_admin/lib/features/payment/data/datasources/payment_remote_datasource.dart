import '../../../../core/network/api_client.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/payment_params.dart';
import '../models/payment_model.dart';

abstract class PaymentRemoteDataSource {
  Future<List<PaymentModel>> getPayments({
    String? clientId,
    PaymentStatus? status,
  });
  Future<PaymentModel> getPayment(String id);
  Future<PaymentModel> createPayment(CreatePaymentParams params);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final ApiClient _apiClient;
  const PaymentRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<PaymentModel>> getPayments({
    String? clientId,
    PaymentStatus? status,
  }) async {
    final response = await _apiClient.dio.get(
      '/api/v1/payments',
      queryParameters: {
        if (clientId != null) 'client_id': clientId,
        if (status != null) 'status': status.name,
      },
    );
    final list = response.data['data'] as List;
    return list
        .map((e) => PaymentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PaymentModel> getPayment(String id) async {
    final response = await _apiClient.dio.get('/api/v1/payments/$id');
    return PaymentModel.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<PaymentModel> createPayment(CreatePaymentParams params) async {
    final response = await _apiClient.dio.post(
      '/api/v1/payments',
      data: {
        'client_id': params.clientId,
        'amount': params.amount,
        if (params.description != null) 'description': params.description,
        if (params.method != null) 'method': params.method,
        if (params.dueDate != null)
          'due_date': params.dueDate!.toIso8601String(),
      },
    );
    return PaymentModel.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }
}
