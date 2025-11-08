part of 'room_bloc.dart';

/// Các sự kiện cho RoomBloc.
abstract class RoomEvent extends Equatable {
  const RoomEvent();
  @override
  List<Object?> get props => [];
}

class FetchRooms extends RoomEvent {
  final int? page;
  const FetchRooms({this.page});
  @override
  List<Object?> get props => [page];
}

class FetchRoomDetail extends RoomEvent {
  final int id;
  const FetchRoomDetail({required this.id});
  @override
  List<Object?> get props => [id];
}

class CreateRoom extends RoomEvent {
  final RoomModel room;
  const CreateRoom({required this.room});
  @override
  List<Object?> get props => [room];
} 

class UpdateRoom extends RoomEvent {
  final RoomModel room;
  const UpdateRoom({required this.room});
  @override
  List<Object?> get props => [room];
}

class DeleteRoom extends RoomEvent{
  final int id;
  const DeleteRoom({required this.id});
  @override
  List<Object?> get props => [id];
}

class UploadRoomImages extends RoomEvent {
  final int id;
  final List<File> files;
  const UploadRoomImages({required this.id,required this.files});
  @override
  List<Object?> get props => [id, files];
}

class UpdateRoomServices extends RoomEvent {
  final int id;
  final List<int> serviceIds;
  const UpdateRoomServices({required this.id,required this.serviceIds});
  @override
  List<Object?> get props => [id, serviceIds];
}

class UpdateRoomAmenities extends RoomEvent {
  final int id;
  final List<int> amenityIds;
  const UpdateRoomAmenities({required this.id,required this.amenityIds});
  @override
  List<Object?> get props => [id, amenityIds];
}