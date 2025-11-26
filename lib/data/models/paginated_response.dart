/// Model dùng để ánh xạ kết quả phân trang (Laravel paginate).
class PaginatedResponse<T> {
  final List<T> data;
  final int currentPage;
  final int lastPage;
  final int total;

  const PaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  bool get hasMore => currentPage < lastPage;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> item) fromJson,
  ) {
    final meta = (json['meta'] as Map<String, dynamic>?) ?? json;
    final List dataList = json['data'] as List? ?? [];
    return PaginatedResponse<T>(
      data: dataList
          .whereType<Map<String, dynamic>>()
          .map((item) => fromJson(item))
          .toList(),
      currentPage: _readInt(meta, 'current_page', fallback: 1),
      lastPage: _readInt(meta, 'last_page', fallback: 1),
      total: _readInt(meta, 'total', fallback: dataList.length),
    );
  }

  static int _readInt(Map<String, dynamic> json, String key,
      {int fallback = 0}) {
    final value = json[key];
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? fallback;
    }
    return fallback;
  }
}

