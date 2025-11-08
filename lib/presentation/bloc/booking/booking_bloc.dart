import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/exceptions.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/repositories/booking_repository.dart';

part 'booking_event.dart';
part 'booking_state.dart';

/// Bloc cho chức năng đặt phòng.
class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository bookingRepository;

  BookingBloc({required this.bookingRepository}) : super(BookingInitial()) {
    on<FetchBookings>(_onFetchBookings);
    on<CreateBookingEvent>(_onCreateBooking);
    on<UpdateBookingStatusEvent>(_onUpdateStatus);
  }

  Future<void> _onFetchBookings(FetchBookings event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      final bookings = await bookingRepository.getBookings(page: event.page);
      emit(BookingsLoaded(bookings: bookings));
    } on AppException catch (e) {
      emit(BookingError(message: e.message));
    }
  }

  Future<void> _onCreateBooking(CreateBookingEvent event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      final booking = await bookingRepository.createBooking(
        roomId: event.roomId,
        checkInDate: event.checkInDate,
        expectedCheckOutDate: event.expectedCheckOutDate,
        rentalType: event.rentalType,
      );
      emit(BookingLoaded(booking: booking));
    } on AppException catch (e) {
      emit(BookingError(message: e.message));
    }
  }

  Future<void> _onUpdateStatus(UpdateBookingStatusEvent event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      final booking = await bookingRepository.updateBookingStatus(event.id, event.status, reason: event.reason);
      emit(BookingLoaded(booking: booking));
    } on AppException catch (e) {
      emit(BookingError(message: e.message));
    }
  }
}