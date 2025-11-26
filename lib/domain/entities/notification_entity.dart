import 'package:equatable/equatable.dart';

/// Thực thể thông báo.
class NotificationEntity extends Equatable {
  final int id;
  final String title;
  final String? content;
  final int? userId;
  final String createdAt;

  const NotificationEntity({
    required this.id,
    required this.title,
    this.content,
    this.userId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, content, userId, createdAt];
}
