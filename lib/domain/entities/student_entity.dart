import 'package:equatable/equatable.dart';

/// Thực thể sinh viên.
class StudentEntity extends Equatable {
  final int id;
  final String studentCode;
  final String? studentClass;
  final String? dateOfBirth;
  final String? gender;
  final String? phone;
  final String? address;

  const StudentEntity({
    required this.id,
    required this.studentCode,
    this.studentClass,
    this.dateOfBirth,
    this.gender,
    this.phone,
    this.address,
  });

  @override
  List<Object?> get props => [id, studentCode, studentClass, dateOfBirth, gender, phone, address];
}