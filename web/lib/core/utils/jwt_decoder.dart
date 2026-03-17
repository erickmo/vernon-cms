import 'dart:convert';

/// Decoder JWT untuk mengekstrak payload tanpa verifikasi signature.
///
/// Digunakan di frontend untuk mendapatkan info user (user_id, email, role)
/// dari access token tanpa perlu API call tambahan.
class JwtDecoder {
  JwtDecoder._();

  /// Mendekode payload JWT dan mengembalikan map isinya.
  ///
  /// JWT format: header.payload.signature (masing-masing base64url-encoded).
  /// Hanya payload (bagian kedua) yang di-decode.
  ///
  /// Returns `null` jika token tidak valid.
  static Map<String, dynamic>? decode(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      return json.decode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Mengekstrak user_id dari JWT token.
  static String? getUserId(String token) {
    final payload = decode(token);
    return payload?['user_id'] as String?;
  }

  /// Mengekstrak email dari JWT token.
  static String? getEmail(String token) {
    final payload = decode(token);
    return payload?['email'] as String?;
  }

  /// Mengekstrak role dari JWT token.
  static String? getRole(String token) {
    final payload = decode(token);
    return payload?['role'] as String?;
  }

  /// Mengecek apakah token sudah expired.
  static bool isExpired(String token) {
    final payload = decode(token);
    if (payload == null) return true;
    final exp = payload['exp'] as int?;
    if (exp == null) return true;
    final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    return DateTime.now().isAfter(expiry);
  }
}
