import '../../../../core/network/api_client.dart';
import '../../domain/entities/client_params.dart';
import '../models/client_model.dart';

abstract class ClientRemoteDataSource {
  Future<List<ClientModel>> getClients({String? search, bool? isActive});
  Future<ClientModel> getClient(String id);
  Future<ClientModel> createClient(CreateClientParams params);
  Future<ClientModel> updateClient(UpdateClientParams params);
  Future<void> deleteClient(String id);
  Future<void> toggleActive(String id);
}

class ClientRemoteDataSourceImpl implements ClientRemoteDataSource {
  final ApiClient _apiClient;
  const ClientRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<ClientModel>> getClients({
    String? search,
    bool? isActive,
  }) async {
    final response = await _apiClient.dio.get(
      '/api/v1/clients',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (isActive != null) 'is_active': isActive,
      },
    );
    final list = response.data['data'] as List;
    return list
        .map((e) => ClientModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ClientModel> getClient(String id) async {
    final response = await _apiClient.dio.get('/api/v1/clients/$id');
    return ClientModel.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<ClientModel> createClient(CreateClientParams params) async {
    final response = await _apiClient.dio.post(
      '/api/v1/clients',
      data: {
        'name': params.name,
        'email': params.email,
        if (params.phone != null) 'phone': params.phone,
        if (params.company != null) 'company': params.company,
        if (params.address != null) 'address': params.address,
      },
    );
    return ClientModel.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<ClientModel> updateClient(UpdateClientParams params) async {
    final response = await _apiClient.dio.put(
      '/api/v1/clients/${params.id}',
      data: {
        'name': params.name,
        'email': params.email,
        if (params.phone != null) 'phone': params.phone,
        if (params.company != null) 'company': params.company,
        if (params.address != null) 'address': params.address,
      },
    );
    return ClientModel.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteClient(String id) async {
    await _apiClient.dio.delete('/api/v1/clients/$id');
  }

  @override
  Future<void> toggleActive(String id) async {
    await _apiClient.dio.patch('/api/v1/clients/$id/toggle-active');
  }
}
