import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../presentation/bloc/room/room_bloc.dart';
import '../datasources/api_service.dart';
import '../models/paginated_response.dart';
import '../models/room_model.dart';

/// Repository xử lý dữ liệu phòng (Room).
class RoomRepository {
  final ApiService apiService;

  RoomRepository({required this.apiService});

  /// Lấy danh sách phòng (kèm phân trang mặc định của Laravel).
  Future<Either<Failure, PaginatedResponse<RoomModel>>> getRooms({
    required Map<String, dynamic> queryParameters,
  }) async {
    try {
      final response = await apiService.getRequest(
        ApiEndpoints.rooms,
        queryParameters: queryParameters,
      );

      final map = _ensurePaginatedMap(response.data);
      final paginated = PaginatedResponse<RoomModel>.fromJson(
        map,
        RoomModel.fromJson,
      );

      return Right(paginated);
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
          ? data['data'] as Map<String, dynamic>
          : data as Map<String, dynamic>;
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

  /// Toggle yêu thích
  Future<void> toggleFavourite(int roomId) async {
    await apiService.postRequest('/rooms/$roomId/favourite');
  }

  /// Lấy danh sách phòng yêu thích của người dùng
  Future<PaginatedResponse<RoomModel>> getMyFavouriteRooms(int page) async {
    final response = await apiService.getRequest('/rooms/favourites/my?page=$page');
    return PaginatedResponse.fromJson(
      response.data,
      (item) => RoomModel.fromJson(item).copyWith(isFavourite: true),
    );
  }

  /// Lấy chi tiết phòng của người dùng
  Future<RoomModel> getMyRoom() async {
    final response = await apiService.getRequest(ApiEndpoints.myRoom);
    final data = response.data;
    final map = data is Map<String, dynamic>
        ? Map<String, dynamic>.from(data['data'] ?? data)
        : <String, dynamic>{};
    return RoomModel.fromJson(map);
  }

  Map<String, dynamic> _ensurePaginatedMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data.containsKey('data')
          ? data
          : {
        'data': data.values
            .whereType<List>()
            .expand((elements) => elements)
            .whereType<Map<String, dynamic>>()
            .toList(),
        'meta': data['meta'] ?? {},
      };
    }
    if (data is List) {
      return {'data': data, 'meta': {}};
    }
    return {'data': <dynamic>[], 'meta': {}};
  }
}
