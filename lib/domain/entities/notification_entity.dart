import 'package:equatable/equatable.dart';

/// Thực thể thông báo.
class NotificationEntity extends Equatable {
  final int id;
  final String title;
  final String? content;
  final bool isRead;
  final int? userId;
  final String createdAt;

  const NotificationEntity({
    required this.id,
    required this.title,
    this.content,
    required this.isRead,
    this.userId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, content, isRead, userId, createdAt];
}