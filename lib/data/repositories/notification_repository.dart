import '../../core/constants/api_endpoints.dart';
import '../../core/error/exceptions.dart';
import '../datasources/api_service.dart';
import '../models/notification_model.dart';

/// Repository xử lý dữ liệu thông báo.
class NotificationRepository {
  final ApiService apiService;

  NotificationRepository({required this.apiService});

  /// Lấy danh sách thông báo của người dùng.
  Future<List<NotificationModel>> getNotifications({int? page}) async {
    try {
      final response = await apiService.getRequest(
        ApiEndpoints.notifications,
        queryParameters: page != null ? {'page': page} : null,
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['data'] as List? ?? [];
      return list.map((e) => NotificationModel.fromJson(e)).toList();
    } on AppException {
      rethrow;
    }
  }

  /// Đánh dấu thông báo đã đọc.
  Future<void> markAsRead(int id) async {
    try {
      await apiService.putRequest(ApiEndpoints.notification(id), data: {'is_read': true});
    } on AppException {
      rethrow;
    }
  }
}