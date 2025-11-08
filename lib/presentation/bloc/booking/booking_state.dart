part of 'booking_bloc.dart';

/// Các trạng thái của BookingBloc.
abstract class BookingState extends Equatable {
  const BookingState();
  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingsLoaded extends BookingState {
  final List<BookingModel> bookings;
  const BookingsLoaded({required this.bookings});
  @override
  List<Object?> get props => [bookings];
}

class BookingLoaded extends BookingState {
  final BookingModel booking;
  const BookingLoaded({required this.booking});
  @override
  List<Object?> get props => [booking];
}

class BookingError extends BookingState {
  final String message;
  const BookingError({required this.message});
  @override
  List<Object?> get props => [message];
}