import 'package:equatable/equatable.dart';

import 'service_entity.dart';

/// Thực thể phòng.
class RoomEntity extends Equatable {
  final int id;
  final String roomCode;
  final int floorId;
  final double pricePerDay;
  final double pricePerMonth;
  final int capacity;
  final int currentOccupancy;
  final bool isActive;
  final String? description;
  final List<String> images;
  final List<ServiceEntity> services;
  final List<int> amenityIds;

  const RoomEntity({
    required this.id,
    required this.roomCode,
    required this.floorId,
    required this.pricePerDay,
    required this.pricePerMonth,
    required this.capacity,
    required this.currentOccupancy,
    required this.isActive,
    this.description,
    this.images = const [],
    this.services = const [],
    this.amenityIds = const [],
  });

  @override
  List<Object?> get props => [
        id,
        roomCode,
        floorId,
        pricePerDay,
        pricePerMonth,
        capacity,
        currentOccupancy,
        isActive,
        description,
        images,
        services,
        amenityIds,
      ];
}