import '../../domain/entities/roommate_entity.dart';

/// Model đại diện cho bạn cùng phòng (roommate).
class RoommateModel {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final String? studentCode;

  const RoommateModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.studentCode,
  });

  factory RoommateModel.fromJson(Map<String, dynamic> json) {
    return RoommateModel(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatar: json['avatar'] as String?,
      studentCode: json['student_code'] as String?,
    );
  }

  RoommateEntity toEntity() {
    return RoommateEntity(
      id: id,
      name: name,
      email: email,
      avatar: avatar,
      studentCode: studentCode,
    );
  }
}
