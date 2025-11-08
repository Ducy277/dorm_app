import '../../domain/entities/room_entity.dart';
import 'service_model.dart';

/// Model đại diện cho phòng trong ký túc xá.
class RoomModel {
  final int id;
  final String roomCode;
  final int floorId;
  final String? floorName;
  final int? branchId;
  final String? branchName;
  final double pricePerDay;
  final double pricePerMonth;
  final int capacity;
  final int currentOccupancy;
  final bool isActive;
  final String? description;
  final List<String>? images;
  final List<ServiceModel>? services;
  final List<int>? amenityIds;

  RoomModel({
    required this.id,
    required this.roomCode,
    required this.floorId,
    required this.floorName,
    required this.branchId,
    required this.branchName,
    required this.pricePerDay,
    required this.pricePerMonth,
    required this.capacity,
    required this.currentOccupancy,
    required this.isActive,
    this.description,
    this.images,
    this.services,
    this.amenityIds,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as int,
      roomCode: json['room_code'] as String,
      floorId: json['floor_id'] as int,
      floorName: json['floor_number']?.toString(),
      branchId: json['id'],
      branchName: json['name'],
      pricePerDay: num.tryParse(json['price_per_day'].toString())?.toDouble() ?? 0,
      pricePerMonth: num.tryParse(json['price_per_month'].toString())?.toDouble() ?? 0,
      capacity: json['capacity'] as int,
      currentOccupancy: json['current_occupancy'] as int,
      isActive: json['is_active'] == true || json['is_active'] == 1,
      description: json['description'] as String?,
      images: (json['images'] as List?)?.map((e) => e['image_path'] as String).toList(),
      services: (json['services'] as List?)?.map((e) => ServiceModel.fromJson(e)).toList(),
      amenityIds: (json['amenities'] as List?)?.map((e) => e['id'] as int).toList(),
    );
  }

  RoomEntity toEntity() {
    return RoomEntity(
      id: id,
      roomCode: roomCode,
      floorId: floorId,
      pricePerDay: pricePerDay,
      pricePerMonth: pricePerMonth,
      capacity: capacity,
      currentOccupancy: currentOccupancy,
      isActive: isActive,
      description: description,
      images: images ?? [],
      services: services?.map((e) => e.toEntity()).toList() ?? [],
      amenityIds: amenityIds ?? [],
    );
  }
}