/// Helper untuk mengekstrak data dari response API.
///
/// API Vernon CMS membungkus semua response sukses dalam `{ "data": { ... } }`
/// dan error dalam `{ "error": "..." }`.
class ApiResponse {
  ApiResponse._();

  /// Mengekstrak field `data` dari response map.
  ///
  /// Jika response sudah berupa map dengan key `data`, kembalikan isinya.
  /// Jika tidak, kembalikan response apa adanya.
  static T extractData<T>(dynamic responseData) {
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      return responseData['data'] as T;
    }
    return responseData as T;
  }

  /// Mengekstrak pesan error dari response error API.
  ///
  /// API mengembalikan `{ "error": "pesan error" }`.
  static String extractError(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      return responseData['error'] as String? ??
          'Terjadi kesalahan pada server';
    }
    return 'Terjadi kesalahan pada server';
  }
}
