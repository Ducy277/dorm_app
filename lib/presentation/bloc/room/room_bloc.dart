import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/models/room_model.dart';
import '../../../data/repositories/room_repository.dart';

part 'room_event.dart';
part 'room_state.dart';

/// Bloc xử lý dữ liệu phòng.
class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final RoomRepository roomRepository;

  RoomBloc({required this.roomRepository}) : super(RoomInitial()) {
    on<FetchRooms>(_onFetchRooms);
    on<FetchRoomDetail>(_onFetchRoomDetail);
    on<CreateRoom>(_onCreateRoom);
    on<UpdateRoom>(_onUpdateRoom);
    on<DeleteRoom>(_onDeleteRoom);
    on<UploadRoomImages>(_onUploadRoomImages);
    on<UpdateRoomServices>(_onUpdateRoomServices);
    on<UpdateRoomAmenities>(_onUpdateRoomAmenities);
  }

  /// Lấy danh sách phòng.
  Future<void> _onFetchRooms(FetchRooms event, Emitter<RoomState> emit) async {
    emit(RoomLoading());
    final result = await roomRepository.getRooms(page: event.page);
    result.fold(
          (failure) => emit(RoomError(message: failure.message)),
          (rooms) => emit(RoomsLoaded(rooms: rooms)),
    );
  }

  /// Lấy chi tiết 1 phòng.
  Future<void> _onFetchRoomDetail(FetchRoomDetail event, Emitter<RoomState> emit) async {
    emit(RoomLoading());
    final result = await roomRepository.getRoom(event.id);
    result.fold(
          (failure) => emit(RoomError(message: failure.message)),
          (room) => emit(RoomLoaded(room: room)),
    );
  }

  /// Tạo phòng mới.
  Future<void> _onCreateRoom(CreateRoom event, Emitter<RoomState> emit) async {
    emit(RoomLoading());
    print('📤 Creating room...');

    final result = await roomRepository.createRoom(event.room);
    result.fold(
          (failure) => emit(RoomError(message: failure.message)),
          (room) => emit(RoomLoaded(room: room)),
    );
  }

  /// Cập nhật thông tin phòng.
  Future<void> _onUpdateRoom(UpdateRoom event, Emitter<RoomState> emit) async {
    emit(RoomLoading());
    final result = await roomRepository.updateRoom(event.room);
    result.fold(
          (failure) => emit(RoomError(message: failure.message)),
          (room) => emit(RoomLoaded(room: room)),
    );
  }

  /// Xóa phòng.
  Future<void> _onDeleteRoom(DeleteRoom event, Emitter<RoomState> emit) async {
    emit(RoomLoading());
    final result = await roomRepository.deleteRoom(event.id);
    result.fold(
          (failure) => emit(RoomError(message: failure.message)),
          (_) => emit(RoomSuccess(message: 'Đã xóa phòng thành công')),
    );
  }

  /// Upload ảnh phòng.
  Future<void> _onUploadRoomImages(UploadRoomImages event, Emitter<RoomState> emit) async {
    emit(RoomLoading());
    final result = await roomRepository.uploadImages(event.id, event.files);
    result.fold(
          (failure) => emit(RoomError(message: failure.message)),
          (_) => emit(RoomSuccess(message: 'Tải ảnh lên thành công')),
    );
  }

  /// Cập nhật danh sách dịch vụ.
  Future<void> _onUpdateRoomServices(UpdateRoomServices event, Emitter<RoomState> emit) async {
    emit(RoomLoading());
    final result = await roomRepository.updateServices(event.id, event.serviceIds);
    result.fold(
          (failure) => emit(RoomError(message: failure.message)),
          (_) => emit(RoomSuccess(message: 'Cập nhật dịch vụ thành công')),
    );
  }

  /// Cập nhật danh sách tiện nghi.
  Future<void> _onUpdateRoomAmenities(UpdateRoomAmenities event, Emitter<RoomState> emit) async {
    emit(RoomLoading());
    final result = await roomRepository.updateAmenities(event.id, event.amenityIds);
    result.fold(
          (failure) => emit(RoomError(message: failure.message)),
          (_) => emit(RoomSuccess(message: 'Cập nhật tiện nghi thành công')),
    );
  }
}