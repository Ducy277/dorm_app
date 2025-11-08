import '../../core/constants/api_endpoints.dart';
import '../../core/error/exceptions.dart';
import '../datasources/api_service.dart';
import '../models/booking_model.dart';

/// Repository xử lý đặt phòng.
class BookingRepository {
  final ApiService apiService;

  BookingRepository({required this.apiService});

  /// Lấy danh sách đơn đặt phòng theo người dùng hiện tại.
  Future<List<BookingModel>> getBookings({int? page}) async {
    try {
      final response = await apiService.getRequest(
        ApiEndpoints.bookings,
        queryParameters: page != null ? {'page': page} : null,
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['data'] as List? ?? [];
      return list.map((e) => BookingModel.fromJson(e)).toList();
    } on AppException {
      rethrow;
    }
  }

  /// Tạo đơn đặt phòng mới.
  Future<BookingModel> createBooking({required int roomId, required String checkInDate, required String expectedCheckOutDate, required String rentalType}) async {
    try {
      final response = await apiService.postRequest(
        ApiEndpoints.bookings,
        data: {
          'room_id': roomId,
          'check_in_date': checkInDate,
          'expected_check_out_date': expectedCheckOutDate,
          'rental_type': rentalType,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return BookingModel.fromJson(data['data']);
    } on AppException {
      rethrow;
    }
  }

  /// Cập nhật trạng thái đơn đặt phòng.
  Future<BookingModel> updateBookingStatus(int id, String status, {String? reason}) async {
    try {
      final response = await apiService.putRequest(
        ApiEndpoints.booking(id),
        data: {
          'status': status,
          if (reason != null) 'reason': reason,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return BookingModel.fromJson(data['data']);
    } on AppException {
      rethrow;
    }
  }
}