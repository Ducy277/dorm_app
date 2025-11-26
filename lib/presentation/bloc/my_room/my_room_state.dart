part of 'my_room_bloc.dart';

abstract class MyRoomState extends Equatable {
  const MyRoomState();

  @override
  List<Object?> get props => [];
}

class MyRoomInitial extends MyRoomState {
  const MyRoomInitial();
}

class MyRoomLoading extends MyRoomState {
  const MyRoomLoading();
}

class MyRoomLoaded extends MyRoomState {
  final RoomEntity room;
  final BookingEntity? activeBooking;
  final List<RoommateEntity> roommates;

  const MyRoomLoaded({
    required this.room,
    this.activeBooking,
    this.roommates = const [],
  });

  @override
  List<Object?> get props => [room, activeBooking, roommates];
}

class MyRoomEmpty extends MyRoomState {
  final String? message;
  const MyRoomEmpty({this.message});

  @override
  List<Object?> get props => [message];
}

class MyRoomError extends MyRoomState {
  final String message;
  const MyRoomError(this.message);

  @override
  List<Object?> get props => [message];
}
