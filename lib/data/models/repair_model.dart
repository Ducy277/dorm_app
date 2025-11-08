import '../../domain/entities/repair_entity.dart';
import 'user_model.dart';
import 'room_model.dart';

/// Model đại diện cho yêu cầu sửa chữa.
class RepairModel {
  final int id;
  final int userId;
  final int roomId;
  final String description;
  final String? imagePath;
  final String status;
  final int? assignedTo;
  final String? completedAt;
  final UserModel? user;
  final RoomModel? room;

  RepairModel({
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

  factory RepairModel.fromJson(Map<String, dynamic> json) {
    return RepairModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      roomId: json['room_id'] as int,
      description: json['description'] as String,
      imagePath: json['image_path'] as String?,
      status: json['status'] as String,
      assignedTo: json['assigned_to'] as int?,
      completedAt: json['completed_at'] as String?,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      room: json['room'] != null ? RoomModel.fromJson(json['room']) : null,
    );
  }

  RepairEntity toEntity() {
    return RepairEntity(
      id: id,
      userId: userId,
      roomId: roomId,
      description: description,
      imagePath: imagePath,
      status: status,
      assignedTo: assignedTo,
      completedAt: completedAt,
      user: user?.toEntity(),
      room: room?.toEntity(),
    );
  }
}