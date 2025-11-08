part of 'room_bloc.dart';

/// Các trạng thái cho RoomBloc.
abstract class RoomState extends Equatable {
  const RoomState();
  @override
  List<Object?> get props => [];
}

class RoomInitial extends RoomState {}

class RoomLoading extends RoomState {}

class RoomsLoaded extends RoomState {
  final List<RoomModel> rooms;
  const RoomsLoaded({required this.rooms});
  @override
  List<Object?> get props => [rooms];
}

class RoomLoaded extends RoomState {
  final RoomModel room;
  const RoomLoaded({required this.room});
  @override
  List<Object?> get props => [room];
}

class RoomSuccess extends RoomState {
  final String message;
  const RoomSuccess({required this.message});
  @override
  List<Object?> get props => [message];
}

class RoomError extends RoomState {
  final String message;
  const RoomError({required this.message});
  @override
  List<Object?> get props => [message];
}