part of 'auth_bloc.dart';

/// Các sự kiện liên quan đến xác thực.
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const RegisterRequested({required this.name, required this.email, required this.password});

  @override
  List<Object?> get props => [name, email, password];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

class FetchProfile extends AuthEvent {
  const FetchProfile();
}

class UpdateProfileRequested extends AuthEvent {
  final String name;
  final String? phone;
  final String? address;
  final String? gender;
  final String? dateOfBirth;
  final String? studentClass;

  const UpdateProfileRequested({
    required this.name,
    this.phone,
    this.address,
    this.gender,
    this.dateOfBirth,
    this.studentClass,
  });

  @override
  List<Object?> get props => [name, phone, address, gender, dateOfBirth, studentClass];
}
