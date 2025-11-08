part of 'auth_bloc.dart';

/// Các trạng thái của Bloc xác thực.
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

/// Trạng thái ban đầu khi chưa xác định.
class AuthInitial extends AuthState {}

/// Trạng thái đang tải (ví dụ đang đăng nhập).
class AuthLoading extends AuthState {}

/// Trạng thái đã xác thực thành công.
class AuthAuthenticated extends AuthState {
  final UserModel user;
  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Trạng thái chưa xác thực.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Trạng thái xảy ra lỗi.
class AuthError extends AuthState {
  final String message;
  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}