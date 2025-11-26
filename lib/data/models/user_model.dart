import '../../domain/entities/student_entity.dart';
import '../../domain/entities/user_entity.dart';
import 'booking_model.dart';

/// Model đại diện cho người dùng, ánh xạ dữ liệu từ API.
class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? avatar;
  final StudentModel? student;
  final BookingModel? activeBooking;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,
    this.student,
    this.activeBooking,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'student',
      avatar: json['avatar'] as String?,
      student: json['student'] != null ? StudentModel.fromJson(json['student']) : null,
      activeBooking: json['active_booking'] != null
          ? BookingModel.fromJson(Map<String, dynamic>.from(json['active_booking']))
          : null,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      role: role,
      avatar: avatar,
      student: student?.toEntity(),
    );
  }
}

/// Model cho thông tin sinh viên (trong bảng students).
class StudentModel {
  final int id;
  final String studentCode;
  final String? studentClass;
  final String? dateOfBirth;
  final String? gender;
  final String? phone;
  final String? address;

  StudentModel({
    required this.id,
    required this.studentCode,
    this.studentClass,
    this.dateOfBirth,
    this.gender,
    this.phone,
    this.address,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] as int,
      studentCode: json['student_code'] as String,
      studentClass: json['class'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      gender: json['gender'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
    );
  }

  StudentEntity toEntity() {
    return StudentEntity(
      id: id,
      studentCode: studentCode,
      studentClass: studentClass,
      dateOfBirth: dateOfBirth,
      gender: gender,
      phone: phone,
      address: address,
    );
  }
}
