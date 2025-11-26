import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final int id;
  final int roomId;
  final int userId;
  final int rating;
  final String comment;
  final String? createdAt;
  final String? userName;

  const ReviewEntity({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.rating,
    required this.comment,
    this.createdAt,
    this.userName,
  });

  @override
  List<Object?> get props => [id, roomId, userId, rating, comment, createdAt, userName];
}

