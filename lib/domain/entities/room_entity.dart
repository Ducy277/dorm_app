import 'package:equatable/equatable.dart';
import 'review_entity.dart';
import 'amenity_entity.dart';
import 'service_entity.dart';
import 'roommate_entity.dart';

/// Thực thể phòng.
class RoomEntity extends Equatable {
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
  final int availableSlots;
  final bool isActive;
  final String? description;
  final String? genderType;
  final bool isFavourite;
  final List<String> images;
  final List<ServiceEntity> services;
  final List<AmenityEntity> amenities;
  final List<int> amenityIds;
  final List<ReviewEntity> reviews;
  final List<RoommateEntity> roommates;

  const RoomEntity({
    required this.id,
    required this.roomCode,
    required this.floorId,
    this.floorName,
    this.branchId,
    this.branchName,
    required this.pricePerDay,
    required this.pricePerMonth,
    required this.capacity,
    required this.currentOccupancy,
    this.availableSlots = 0,
    required this.isActive,
    this.genderType,
    this.description,
    this.isFavourite = false,
    this.images = const [],
    this.services = const [],
    this.amenities = const [],
    this.amenityIds = const [],
    this.reviews = const[],
    this.roommates = const [],
  });

  @override
  List<Object?> get props => [
        id,
        roomCode,
        floorId,
        floorName,
        branchId,
        branchName,
        pricePerDay,
        pricePerMonth,
        capacity,
        currentOccupancy,
        availableSlots,
        isActive,
        genderType,
        description,
        isFavourite,
        images,
        services,
        amenities,
        amenityIds,
        reviews,
        roommates,
      ];
}
