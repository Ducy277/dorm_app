import '../../domain/entities/notification_entity.dart';

/// Model đại diện cho thông báo.
class NotificationModel {
  final int id;
  final String title;
  final String? content;
  final int? userId;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.createdAt,
    this.content,
    this.userId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String?,
      userId: json['user_id'] as int?,
      createdAt: json['created_at'] as String,
    );
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      title: title,
      content: content,
      userId: userId,
      createdAt: createdAt,
    );
  }
}
