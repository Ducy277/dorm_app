import 'package:equatable/equatable.dart';

/// Thực thể bạn cùng phòng.
class RoommateEntity extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final String? studentCode;

  const RoommateEntity({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.studentCode,
  });

  @override
  List<Object?> get props => [id, name, email, avatar, studentCode];
}
