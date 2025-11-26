import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/exceptions.dart';
import '../../../data/models/active_booking_model.dart';
import '../../../data/repositories/room_repository.dart';
import '../../../domain/entities/room_entity.dart';
import '../../../domain/entities/roommate_entity.dart';
import '../../../domain/entities/booking_entity.dart';

part 'my_room_event.dart';
part 'my_room_state.dart';

class MyRoomBloc extends Bloc<MyRoomEvent, MyRoomState> {
  final RoomRepository roomRepository;

  MyRoomBloc({required this.roomRepository}) : super(const MyRoomInitial()) {
    on<MyRoomRequested>(_onMyRoomRequested);
  }

  Future<void> _onMyRoomRequested(
    MyRoomRequested event,
    Emitter<MyRoomState> emit,
  ) async {
    emit(const MyRoomLoading());
    try {
      final roomModel = await roomRepository.getMyRoom();
      final activeBookingModel =
          _selectActiveBooking(roomModel.activeBookings, event.userId);
      final roomEntity = roomModel.toEntity();

      emit(
        MyRoomLoaded(
          room: roomEntity,
          activeBooking: _mapActiveBooking(activeBookingModel, roomEntity),
          roommates: roomModel.roommates.map((e) => e.toEntity()).toList(),
        ),
      );
    } on NotFoundException catch (e) {
      emit(MyRoomEmpty(message: e.message));
    } on AuthenticationException catch (e) {
      emit(MyRoomError(e.message));
    } on AppException catch (e) {
      emit(MyRoomError(e.message));
    } catch (e) {
      emit(MyRoomError(e.toString()));
    }
  }

  ActiveBookingModel? _selectActiveBooking(
    List<ActiveBookingModel> bookings,
    int? userId,
  ) {
    if (bookings.isEmpty) return null;

    if (userId != null) {
      final myBookings = bookings.where((b) => b.userId == userId).toList();
      if (myBookings.isNotEmpty) {
        return myBookings.firstWhere(
          (b) => b.status.toLowerCase() == 'active',
          orElse: () => myBookings.first,
        );
      }
    }

    return bookings.firstWhere(
      (b) => b.status.toLowerCase() == 'active',
      orElse: () => bookings.first,
    );
  }

  BookingEntity? _mapActiveBooking(
    ActiveBookingModel? model,
    RoomEntity room,
  ) {
    if (model == null) return null;
    return model.toEntity(room);
  }
}
