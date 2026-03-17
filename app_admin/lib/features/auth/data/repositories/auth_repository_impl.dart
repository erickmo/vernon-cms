import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/login_params.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SharedPreferences prefs;

  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.prefs,
  });

  @override
  Future<Either<Failure, void>> login(LoginParams params) async {
    try {
      final response = await remoteDataSource.login(
        LoginRequestModel(email: params.email, password: params.password),
      );
      await prefs.setString(AppConstants.accessTokenKey, response.accessToken);
      await prefs.setString(
          AppConstants.refreshTokenKey, response.refreshToken);
      return const Right(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return const Left(ServerFailure('Email atau password salah'));
      }
      return Left(ServerFailure(
        e.message ?? 'Gagal login',
        statusCode: e.response?.statusCode,
      ));
    } catch (_) {
      return const Left(ServerFailure('Terjadi kesalahan'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    await prefs.remove(AppConstants.accessTokenKey);
    await prefs.remove(AppConstants.refreshTokenKey);
    return const Right(null);
  }
}
