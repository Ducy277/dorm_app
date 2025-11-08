import 'package:equatable/equatable.dart';

import 'user_entity.dart';
import 'room_entity.dart';

/// Thực thể yêu cầu sửa chữa.
class RepairEntity extends Equatable {
  final int id;
  final int userId;
  final int roomId;
  final String description;
  final String? imagePath;
  final String status;
  final int? assignedTo;
  final String? completedAt;
  final UserEntity? user;
  final RoomEntity? room;

  const RepairEntity({
    required this.id,
    required this.userId,
    required this.roomId,
    required this.description,
    required this.status,
    this.imagePath,
    this.assignedTo,
    this.completedAt,
    this.user,
    this.room,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        roomId,
        description,
        imagePath,
        status,
        assignedTo,
        completedAt,
        user,
        room,
      ];
}