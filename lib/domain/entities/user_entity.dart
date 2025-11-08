import 'package:equatable/equatable.dart';

import 'student_entity.dart';

/// Thực thể người dùng ở tầng domain.
class UserEntity extends Equatable {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? avatar;
  final StudentEntity? student;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,
    this.student,
  });

  @override
  List<Object?> get props => [id, name, email, role, avatar, student];
}