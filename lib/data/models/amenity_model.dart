import '../../domain/entities/amenity_entity.dart';

/// Model đại diện cho tiện nghi trong phòng.
class AmenityModel {
  final int id;
  final String name;
  final String? description;

  AmenityModel({
    required this.id,
    required this.name,
    this.description,
  });

  factory AmenityModel.fromJson(dynamic json) {
    if (json is int) {
      return AmenityModel(id: json, name: '');
    }
    final map = json as Map<String, dynamic>;
    return AmenityModel(
      id: map['id'] as int,
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString(),
    );
  }

  AmenityEntity toEntity() {
    return AmenityEntity(
      id: id,
      name: name,
      description: description,
    );
  }
}

