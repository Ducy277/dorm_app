part of 'room_bloc.dart';

/// Các sự kiện cho RoomBloc.
abstract class RoomEvent extends Equatable {
  const RoomEvent();

  @override
  List<Object?> get props => [];
}

class FetchRooms extends RoomEvent {
  final bool showLoading;
  const FetchRooms({this.showLoading = true});

  @override
  List<Object?> get props => [showLoading];
}

class LoadMoreRooms extends RoomEvent {
  const LoadMoreRooms();

  @override
  List<Object?> get props => [];
}

class UpdateRoomFilters extends RoomEvent {
  final RoomFilters filters;
  const UpdateRoomFilters(this.filters);

  @override
  List<Object?> get props => [filters];
}

class FetchRoomDetail extends RoomEvent {
  final int id;
  const FetchRoomDetail({required this.id});

  @override
  List<Object?> get props => [id];
}

class SubmitReview extends RoomEvent {
  final int roomId;
  final int rating;
  final String comment;
  const SubmitReview(this.roomId, this.rating, this.comment);

  @override
  List<Object?> get props => [roomId, rating, comment];
}

class ToggleFavouriteRoom extends RoomEvent {
  final int roomId;
  const ToggleFavouriteRoom(this.roomId);

  @override
  List<Object?> get props => [roomId];
}
