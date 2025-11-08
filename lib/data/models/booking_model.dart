import '../../domain/entities/booking_entity.dart';
import 'user_model.dart';
import 'room_model.dart';

/// Model đại diện cho đặt phòng (booking).
class BookingModel {
  final int id;
  final int userId;
  final int roomId;
  final String bookingType;
  final String rentalType;
  final String checkInDate;
  final String expectedCheckOutDate;
  final String? actualCheckOutDate;
  final String status;
  final UserModel? user;
  final RoomModel? room;

  BookingModel({
    required this.id,
    required this.userId,
    required this.roomId,
    required this.bookingType,
    required this.rentalType,
    required this.checkInDate,
    required this.expectedCheckOutDate,
    required this.status,
    this.actualCheckOutDate,
    this.user,
    this.room,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      roomId: json['room_id'] as int,
      bookingType: json['booking_type'] as String,
      rentalType: json['rental_type'] as String,
      checkInDate: json['check_in_date'] as String,
      expectedCheckOutDate: json['expected_check_out_date'] as String,
      actualCheckOutDate: json['actual_check_out_date'] as String?,
      status: json['status'] as String,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      room: json['room'] != null ? RoomModel.fromJson(json['room']) : null,
    );
  }

  BookingEntity toEntity() {
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
      user: user?.toEntity(),
      room: room?.toEntity(),
    );
  }
}