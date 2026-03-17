import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/api_token.dart';
import '../../domain/usecases/create_api_token_usecase.dart';
import '../../domain/usecases/delete_api_token_usecase.dart';
import '../../domain/usecases/get_api_tokens_usecase.dart';
import '../../domain/usecases/toggle_api_token_usecase.dart';
import '../../domain/usecases/update_api_token_usecase.dart';

part 'api_token_state.dart';
part 'api_token_cubit.freezed.dart';

/// Cubit untuk mengelola state halaman API token.
class ApiTokenCubit extends Cubit<ApiTokenState> {
  final GetApiTokensUseCase _getTokensUseCase;
  final CreateApiTokenUseCase _createTokenUseCase;
  final UpdateApiTokenUseCase _updateTokenUseCase;
  final DeleteApiTokenUseCase _deleteTokenUseCase;
  final ToggleApiTokenUseCase _toggleTokenUseCase;

  ApiTokenCubit({
    required GetApiTokensUseCase getTokensUseCase,
    required CreateApiTokenUseCase createTokenUseCase,
    required UpdateApiTokenUseCase updateTokenUseCase,
    required DeleteApiTokenUseCase deleteTokenUseCase,
    required ToggleApiTokenUseCase toggleTokenUseCase,
  })  : _getTokensUseCase = getTokensUseCase,
        _createTokenUseCase = createTokenUseCase,
        _updateTokenUseCase = updateTokenUseCase,
        _deleteTokenUseCase = deleteTokenUseCase,
        _toggleTokenUseCase = toggleTokenUseCase,
        super(const ApiTokenState.initial());

  /// Memuat daftar API token.
  Future<void> loadTokens() async {
    emit(const ApiTokenState.loading());

    final result = await _getTokensUseCase();

    result.fold(
      (failure) => emit(ApiTokenState.error(failure.message)),
      (tokens) => emit(ApiTokenState.loaded(tokens: tokens)),
    );
  }

  /// Membuat API token baru. Mengembalikan token dengan full token string.
  Future<ApiToken?> createToken(ApiToken token) async {
    final result = await _createTokenUseCase(token);

    return result.fold(
      (failure) {
        emit(ApiTokenState.error(failure.message));
        return null;
      },
      (createdToken) {
        loadTokens();
        return createdToken;
      },
    );
  }

  /// Memperbarui API token.
  Future<bool> updateToken(ApiToken token) async {
    final result = await _updateTokenUseCase(token);

    return result.fold(
      (failure) {
        emit(ApiTokenState.error(failure.message));
        return false;
      },
      (_) {
        loadTokens();
        return true;
      },
    );
  }

  /// Menghapus API token.
  Future<bool> deleteToken(String id) async {
    final result = await _deleteTokenUseCase(id);

    return result.fold(
      (failure) {
        emit(ApiTokenState.error(failure.message));
        return false;
      },
      (_) {
        loadTokens();
        return true;
      },
    );
  }

  /// Toggle status aktif API token.
  Future<bool> toggleTokenActive(String id) async {
    final result = await _toggleTokenUseCase(id);

    return result.fold(
      (failure) {
        emit(ApiTokenState.error(failure.message));
        return false;
      },
      (_) {
        loadTokens();
        return true;
      },
    );
  }
}
