import '../../core/constants/api_endpoints.dart';
import '../../core/error/exceptions.dart';
import '../datasources/api_service.dart';
import '../models/booking_model.dart';

/// Repository xử lý tác vụ đặt phòng.
class BookingRepository {
  final ApiService apiService;

  BookingRepository({required this.apiService});

  /// Lấy danh sách đơn đặt phòng của người dùng hiện tại.
  Future<List<BookingModel>> getBookings({int? page}) async {
    try {
      final response = await apiService.getRequest(
        ApiEndpoints.bookingsMy,
        queryParameters: page != null ? {'page': page} : null,
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['data'] as List? ?? [];
      return list.map((e) => BookingModel.fromJson(e)).toList();
    } on AppException {
      rethrow;
    }
  }

  /// Tạo đơn đặt phòng (registration/extension/transfer).
  Future<BookingModel> createBooking({
    required int roomId,
    required String bookingType,
    required String checkInDate,
    required String expectedCheckOutDate,
    required String rentalType,
    String? reason,
  }) async {
    try {
      final response = await apiService.postRequest(
        ApiEndpoints.bookings,
        data: {
          'room_id': roomId,
          'booking_type': bookingType,
          'check_in_date': checkInDate,
          'expected_check_out_date': expectedCheckOutDate,
          'rental_type': rentalType,
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return BookingModel.fromJson(data);
    } on AppException {
      rethrow;
    }
  }

  /// Cập nhật trạng thái đơn đặt phòng.
  Future<BookingModel> updateBookingStatus(
    int id,
    String status, {
    String? reason,
  }) async {
    try {
      final response = await apiService.putRequest(
        ApiEndpoints.booking(id),
        data: {
          'status': status,
          if (reason != null) 'reason': reason,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return BookingModel.fromJson(data);
    } on AppException {
      rethrow;
    }
  }

  /// Gửi yêu cầu trả phòng
  Future<BookingModel> requestReturn({String? reason}) async {
    try {
      final response = await apiService.postRequest(
        ApiEndpoints.bookingsReturn,
        data: {
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return BookingModel.fromJson(data);
    } on AppException {
      rethrow;
    }
  }

  /// Huỷ yêu cầu (chỉ khi pending và thuộc về user)
  Future<void> cancelBooking(int id) async {
    try {
      await apiService.deleteRequest(ApiEndpoints.booking(id));
    } on AppException {
      rethrow;
    }
  }
}
