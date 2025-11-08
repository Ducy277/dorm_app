part of 'booking_bloc.dart';

/// Các sự kiện của BookingBloc.
abstract class BookingEvent extends Equatable {
  const BookingEvent();
  @override
  List<Object?> get props => [];
}

class FetchBookings extends BookingEvent {
  final int? page;
  const FetchBookings({this.page});
  @override
  List<Object?> get props => [page];
}

class CreateBookingEvent extends BookingEvent {
  final int roomId;
  final String checkInDate;
  final String expectedCheckOutDate;
  final String rentalType;
  const CreateBookingEvent({required this.roomId, required this.checkInDate, required this.expectedCheckOutDate, required this.rentalType});
  @override
  List<Object?> get props => [roomId, checkInDate, expectedCheckOutDate, rentalType];
}

class UpdateBookingStatusEvent extends BookingEvent {
  final int id;
  final String status;
  final String? reason;
  const UpdateBookingStatusEvent({required this.id, required this.status, this.reason});
  @override
  List<Object?> get props => [id, status, reason];
}