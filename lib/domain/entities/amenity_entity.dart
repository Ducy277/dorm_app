import 'package:equatable/equatable.dart';

/// Thực thể tiện nghi của phòng.
class AmenityEntity extends Equatable {
  final int id;
  final String name;
  final String? description;

  const AmenityEntity({
    required this.id,
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [id, name, description];
}

