import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';

/// Exception khusus untuk error dari cache/storage.
class CacheException implements Exception {
  /// Pesan error.
  final String message;

  const CacheException(this.message);
}

/// Datasource lokal untuk menyimpan data autentikasi.
abstract class AuthLocalDataSource {
  /// Simpan access token.
  Future<void> saveAccessToken(String token);

  /// Simpan refresh token.
  Future<void> saveRefreshToken(String token);

  /// Ambil access token.
  String? getAccessToken();

  /// Ambil refresh token.
  String? getRefreshToken();

  /// Hapus semua token.
  Future<void> clearTokens();

  /// Simpan email untuk remember me.
  Future<void> saveRememberedEmail(String email);

  /// Ambil email yang disimpan.
  String? getRememberedEmail();

  /// Hapus email yang disimpan.
  Future<void> clearRememberedEmail();
}

/// Implementasi [AuthLocalDataSource] menggunakan SharedPreferences.
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences _prefs;

  static const String _rememberedEmailKey = 'remembered_email';

  const AuthLocalDataSourceImpl(this._prefs);

  @override
  Future<void> saveAccessToken(String token) async {
    await _prefs.setString(AppConstants.accessTokenKey, token);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await _prefs.setString(AppConstants.refreshTokenKey, token);
  }

  @override
  String? getAccessToken() {
    return _prefs.getString(AppConstants.accessTokenKey);
  }

  @override
  String? getRefreshToken() {
    return _prefs.getString(AppConstants.refreshTokenKey);
  }

  @override
  Future<void> clearTokens() async {
    await _prefs.remove(AppConstants.accessTokenKey);
    await _prefs.remove(AppConstants.refreshTokenKey);
  }

  @override
  Future<void> saveRememberedEmail(String email) async {
    await _prefs.setString(_rememberedEmailKey, email);
  }

  @override
  String? getRememberedEmail() {
    return _prefs.getString(_rememberedEmailKey);
  }

  @override
  Future<void> clearRememberedEmail() async {
    await _prefs.remove(_rememberedEmailKey);
  }
}
