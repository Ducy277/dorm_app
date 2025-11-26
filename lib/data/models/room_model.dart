import '../../domain/entities/room_entity.dart';
import '../../domain/entities/roommate_entity.dart';
import 'active_booking_model.dart';
import 'review_model.dart';
import 'amenity_model.dart';
import 'service_model.dart';
import 'roommate_model.dart';


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
  final int availableSlots;
  final bool isActive;
  final String? description;
  final String? genderType;
  final bool isFavourite;
  final List<String> images;
  final List<ServiceModel> services;
  final List<AmenityModel> amenities;
  final List<int> amenityIds;
  final List<ReviewModel> reviews;
  final List<RoommateModel> roommates;
  final List<ActiveBookingModel> activeBookings;

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
    required this.availableSlots,
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
    this.activeBookings = const [],
  });

  RoomModel copyWith({
    bool? isFavourite,
  }) {
    return RoomModel(
      id: id,
      roomCode: roomCode,
      floorId: floorId,
      floorName: floorName,
      branchId: branchId,
      branchName: branchName,
      pricePerDay: pricePerDay,
      pricePerMonth: pricePerMonth,
      capacity: capacity,
      currentOccupancy: currentOccupancy,
      availableSlots: availableSlots,
      isActive: isActive,
      genderType: genderType,
      description: description,
      isFavourite: isFavourite ?? this.isFavourite,
      images: images,
      services: services,
      amenities: amenities,
      amenityIds: amenityIds,
      reviews: reviews,
      roommates: roommates,
      activeBookings: activeBookings,
    );
  }

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    final floor = json['floor'] as Map<String, dynamic>?;
    final branch = (floor?['branch'] as Map<String, dynamic>?) ??
        json['branch'] as Map<String, dynamic>?;

    final amenitiesRaw = json['amenities'];
    final mappedAmenities = _mapAmenities(amenitiesRaw);
    final images = _mapImages(json['images']);
    final genderType =
        json['gender_type']?.toString() ?? floor?['gender_type']?.toString();
    final services = (json['services'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(ServiceModel.fromJson)
            .toList() ??
        const [];

    final reviewsJson = json['reviews'] as List? ?? [];
    final reviews = reviewsJson
        .whereType<Map<String, dynamic>>()
        .map((e) => ReviewModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final roommates = (json['roommates'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((e) => RoommateModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final activeBookings = (json['active_bookings'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((e) => ActiveBookingModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final capacity = (json['capacity'] as num?)?.toInt() ?? 0;
    final occupancy = (json['current_occupancy'] as num?)?.toInt() ?? 0;
    final availableSlots =
        (json['available_slots'] as num?)?.toInt() ?? (capacity - occupancy);

    return RoomModel(
      id: json['id'] as int,
      roomCode: json['room_code']?.toString() ?? '',
      floorId: (floor?['id'] ?? json['floor_id']) as int,
      floorName: floor?['name']?.toString() ??
          floor?['floor_number']?.toString() ??
          json['floor_number']?.toString(),
      branchId: (branch?['id'] ?? json['branch_id']) as int?,
      branchName:
          branch?['name']?.toString() ?? json['branch_name']?.toString(),
      pricePerDay:
          num.tryParse(json['price_per_day'].toString())?.toDouble() ?? 0,
      pricePerMonth:
          num.tryParse(json['price_per_month'].toString())?.toDouble() ?? 0,
      capacity: capacity,
      currentOccupancy: occupancy,
      availableSlots: availableSlots < 0 ? 0 : availableSlots,
      isActive: json['is_active'] == true || json['is_active'] == 1,
      isFavourite: _readFavourite(json),
      description: json['description']?.toString(),
      genderType: genderType,
      images: images,
      services: services,
      amenities: mappedAmenities,
      amenityIds: mappedAmenities.isNotEmpty
          ? mappedAmenities.map((e) => e.id).toList()
          : _mapAmenityIds(amenitiesRaw),
      reviews: reviews,
      roommates: roommates,
      activeBookings: activeBookings,
    );
  }

  static List<String> _mapImages(dynamic raw) {
    final result = <String>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is String) {
          result.add(item);
        } else if (item is Map<String, dynamic>) {
          final path = item['url'] ??
              item['image_url'] ??
              item['image_path'] ??
              item['path'];
          if (path is String && path.isNotEmpty) {
            result.add(path);
          }
        }
      }
    }
    return result;
  }

  static List<AmenityModel> _mapAmenities(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map(AmenityModel.fromJson)
          .toList();
    }
    return const [];
  }

  static List<int> _mapAmenityIds(dynamic raw) {
    if (raw is List) {
      return raw
          .map((e) {
            if (e is int) return e;
            if (e is Map<String, dynamic>) {
              final id = e['id'];
              if (id is int) return id;
            }
            return null;
          })
          .whereType<int>()
          .toList();
    }
    return const [];
  }

  static bool _readFavourite(Map<String, dynamic> json) {
    final fav = json['is_favourite'] ?? json['is_favorited'] ?? json['favourited'];
    if (fav is bool) return fav;
    if (fav is num) return fav == 1;
    if (fav is String) return fav == '1' || fav.toLowerCase() == 'true';
    return false;
  }

  RoomEntity toEntity() {
    return RoomEntity(
      id: id,
      roomCode: roomCode,
      floorId: floorId,
      floorName: floorName,
      branchId: branchId,
      branchName: branchName,
      pricePerDay: pricePerDay,
      pricePerMonth: pricePerMonth,
      capacity: capacity,
      currentOccupancy: currentOccupancy,
      availableSlots: availableSlots,
      isActive: isActive,
      isFavourite: isFavourite,
      genderType: genderType,
      description: description,
      images: images,
      services: services.map((e) => e.toEntity()).toList(),
      amenities: amenities.map((e) => e.toEntity()).toList(),
      amenityIds: amenityIds,
      reviews: reviews.map((e) => e.toEntity()).toList(),
      roommates: roommates.map((e) => e.toEntity()).toList(),
    );
  }
}
