import 'package:equatable/equatable.dart';

import 'user_entity.dart';
import 'room_entity.dart';

/// Thực thể đơn đặt phòng.
class BookingEntity extends Equatable {
  final int id;
  final int userId;
  final int roomId;
  final String bookingType;
  final String rentalType;
  final String checkInDate;
  final String expectedCheckOutDate;
  final String? actualCheckOutDate;
  final String status;
  final String? reason;
  final UserEntity? user;
  final RoomEntity? room;

  const BookingEntity({
    required this.id,
    required this.userId,
    required this.roomId,
    required this.bookingType,
    required this.rentalType,
    required this.checkInDate,
    required this.expectedCheckOutDate,
    this.actualCheckOutDate,
    required this.status,
    this.reason,
    this.user,
    this.room,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        roomId,
        bookingType,
        rentalType,
        checkInDate,
        expectedCheckOutDate,
        actualCheckOutDate,
        status,
        reason,
        user,
        room,
      ];
}
