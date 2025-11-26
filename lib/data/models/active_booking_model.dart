import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/room_entity.dart';

/// Model giản lược cho booking đang hoạt động của phòng hiện tại.
class ActiveBookingModel {
  final int id;
  final int userId;
  final int roomId;
  final String bookingType;
  final String rentalType;
  final String checkInDate;
  final String expectedCheckOutDate;
  final String? actualCheckOutDate;
  final String status;

  const ActiveBookingModel({
    required this.id,
    required this.userId,
    required this.roomId,
    required this.bookingType,
    required this.rentalType,
    required this.checkInDate,
    required this.expectedCheckOutDate,
    this.actualCheckOutDate,
    required this.status,
  });

  factory ActiveBookingModel.fromJson(Map<String, dynamic> json) {
    return ActiveBookingModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      roomId: json['room_id'] as int,
      bookingType: json['booking_type'] as String? ?? '',
      rentalType: json['rental_type'] as String? ?? '',
      checkInDate: json['check_in_date']?.toString() ?? '',
      expectedCheckOutDate: json['expected_check_out_date']?.toString() ?? '',
      actualCheckOutDate: json['actual_check_out_date']?.toString(),
      status: json['status']?.toString() ?? '',
    );
  }

  BookingEntity toEntity(RoomEntity room) {
    return BookingEntity(
      id: id,
      userId: userId,
      roomId: roomId,
      bookingType: bookingType,
      rentalType: rentalType,
      checkInDate: checkInDate,
      expectedCheckOutDate: expectedCheckOutDate,
      actualCheckOutDate: actualCheckOutDate,
      status: status,
      user: null,
      room: room,
    );
  }
}
