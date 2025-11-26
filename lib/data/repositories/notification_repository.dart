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

  /// Lấy chi tiết 1 thông báo.
  Future<NotificationModel> getNotificationDetail(int id) async {
    try {
      final response = await apiService.getRequest(
        ApiEndpoints.notification(id),
      );
      final data = response.data as Map<String, dynamic>;
      final item = data['data'] ?? data;
      return NotificationModel.fromJson(Map<String, dynamic>.from(item));
    } on AppException {
      rethrow;
    }
  }
}
