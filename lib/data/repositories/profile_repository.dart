import '../../core/constants/api_endpoints.dart';
import '../../core/error/exceptions.dart';
import '../datasources/api_service.dart';
import '../models/booking_model.dart';

/// Repository lấy thông tin hồ sơ và phòng hiện tại của sinh viên.
class ProfileRepository {
  final ApiService apiService;

  ProfileRepository({required this.apiService});

  /// Lấy booking đang hoạt động nếu có từ endpoint /me.
  Future<BookingModel?> getMyActiveBooking() async {
    try {
      final response = await apiService.getRequest(ApiEndpoints.me);
      final data = response.data as Map<String, dynamic>;
      final me = data['data'] ?? data;
      final active = me['active_booking'];
      if (active == null) return null;
      return BookingModel.fromJson(Map<String, dynamic>.from(active));
    } on AppException {
      rethrow;
    }
  }
}

