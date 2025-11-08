import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../datasources/api_service.dart';
import '../models/room_model.dart';

/// Repository xử lý dữ liệu phòng (Room).
class RoomRepository {
  final ApiService apiService;

  RoomRepository({required this.apiService});

  /// Lấy danh sách phòng.
  Future<Either<Failure, List<RoomModel>>> getRooms({int? page}) async {
    try {
      final response = await apiService.getRequest(
        ApiEndpoints.rooms,
        queryParameters: page != null ? {'page': page} : null,
      );

      final data = response.data;
      final list = (data is Map<String, dynamic> ? data['data'] : data) as List? ?? [];
      final rooms = list.map((e) => RoomModel.fromJson(e)).toList();

      return Right(rooms);
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Lấy chi tiết một phòng.
  Future<Either<Failure, RoomModel>> getRoom(int id) async {
    try {
      final response = await apiService.getRequest(ApiEndpoints.room(id));
      final data = response.data;
      final map = (data is Map<String, dynamic> && data['data'] != null)
          ? data['data']
          : data;
      final room = RoomModel.fromJson(map);

      return Right(room);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Tạo phòng mới.
  Future<Either<Failure, RoomModel>> createRoom(RoomModel room) async {
    try {
      final response = await apiService.postRequest(
        ApiEndpoints.rooms,
        data: {
          'room_code': room.roomCode,
          'floor_id': room.floorId,
          'price_per_day': room.pricePerDay,
          'price_per_month': room.pricePerMonth,
          'capacity': room.capacity,
          'current_occupancy': room.currentOccupancy,
          'is_active': room.isActive,
          'description': room.description,
          'services': room.services?.map((e) => e.id).toList(),
          'amenities': room.amenityIds,
        },
      );

      final data = response.data;
      final map = (data is Map<String, dynamic> && data['data'] != null)
          ? data['data']
          : data;

      return Right(RoomModel.fromJson(map));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Cập nhật thông tin phòng.
  Future<Either<Failure, RoomModel>> updateRoom(RoomModel room) async {
    try {
      final response = await apiService.putRequest(
        ApiEndpoints.room(room.id),
        data: {
          'room_code': room.roomCode,
          'floor_id': room.floorId,
          'price_per_day': room.pricePerDay,
          'price_per_month': room.pricePerMonth,
          'capacity': room.capacity,
          'current_occupancy': room.currentOccupancy,
          'is_active': room.isActive,
          'description': room.description,
        },
      );

      final data = response.data;
      final map = (data is Map<String, dynamic> && data['data'] != null)
          ? data['data']
          : data;

      return Right(RoomModel.fromJson(map));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Xóa phòng.
  Future<Either<Failure, Unit>> deleteRoom(int id) async {
    try {
      await apiService.deleteRequest(ApiEndpoints.room(id));
      return const Right(unit);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Upload ảnh phòng.
  Future<Either<Failure, Unit>> uploadImages(int roomId, List<File> images) async {
    try {
      final formData = FormData.fromMap({
        'images': [
          for (final img in images)
            await MultipartFile.fromFile(img.path, filename: img.path.split('/').last),
        ],
      });

      await apiService.postMultipartRequest(ApiEndpoints.roomImages(roomId), data: formData);

      return const Right(unit);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Cập nhật dịch vụ của phòng.
  Future<Either<Failure, Unit>> updateServices(int roomId, List<int> serviceIds) async {
    try {
      await apiService.putRequest(
        ApiEndpoints.roomServices(roomId),
        data: {'services': serviceIds},
      );
      return const Right(unit);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Cập nhật tiện nghi của phòng.
  Future<Either<Failure, Unit>> updateAmenities(int roomId, List<int> amenityIds) async {
    try {
      await apiService.putRequest(
        ApiEndpoints.roomAmenities(roomId),
        data: {'amenities': amenityIds},
      );
      return const Right(unit);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
