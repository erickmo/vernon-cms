import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(LoginRequestModel request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;
  const AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    final response = await _apiClient.dio.post(
      '/api/v1/auth/login',
      data: request.toJson(),
    );
    return LoginResponseModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }
}
