/// Generic paginated response wrapper for list API responses.
///
/// API returns: `{ "data": { "items": [...], "total": N, "page": N, "limit": N } }`
class PaginatedResponse<T> {
  /// The list of items in the current page.
  final List<T> items;

  /// Total number of items across all pages.
  final int total;

  /// Current page number.
  final int page;

  /// Number of items per page.
  final int limit;

  const PaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  /// Parse from the API response data map.
  ///
  /// [data] is the `response.data['data']` map.
  /// [fromJson] converts each item JSON map to type [T].
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> data,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final itemsList = (data['items'] as List<dynamic>?) ?? [];
    return PaginatedResponse(
      items: itemsList
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (data['total'] as num?)?.toInt() ?? 0,
      page: (data['page'] as num?)?.toInt() ?? 1,
      limit: (data['limit'] as num?)?.toInt() ?? 20,
    );
  }
}
