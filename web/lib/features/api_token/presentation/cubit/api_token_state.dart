part of 'api_token_cubit.dart';

/// State untuk halaman API token.
@freezed
sealed class ApiTokenState with _$ApiTokenState {
  /// State awal.
  const factory ApiTokenState.initial() = ApiTokenInitial;

  /// Sedang memuat data token.
  const factory ApiTokenState.loading() = ApiTokenLoading;

  /// Data berhasil dimuat.
  const factory ApiTokenState.loaded({
    required List<ApiToken> tokens,
  }) = ApiTokenLoaded;

  /// Gagal memuat data.
  const factory ApiTokenState.error(String message) = ApiTokenError;
}
