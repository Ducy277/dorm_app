part of 'my_room_bloc.dart';

abstract class MyRoomEvent extends Equatable {
  const MyRoomEvent();

  @override
  List<Object?> get props => [];
}

class MyRoomRequested extends MyRoomEvent {
  final int? userId;
  const MyRoomRequested({this.userId});

  @override
  List<Object?> get props => [userId];
}
