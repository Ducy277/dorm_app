import '../../domain/entities/review_entity.dart';

class ReviewModel {
  final int id;
  final int roomId;
  final int userId;
  final int rating;
  final String comment;
  final String? createdAt;
  final String? userName;

  ReviewModel({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.rating,
    required this.comment,
    this.createdAt,
    this.userName,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return ReviewModel(
      id: json['id'] as int,
      roomId: json['room_id'] as int,
      userId: json['user_id'] as int,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
      userName: user?['name']?.toString() ?? json['user_name']?.toString(),
    );
  }

  ReviewEntity toEntity() {
    return ReviewEntity(
      id: id,
      roomId: roomId,
      userId: userId,
      rating: rating,
      comment: comment,
      createdAt: createdAt,
      userName: userName,
    );
  }
}

