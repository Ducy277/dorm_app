import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/exceptions.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Bloc xử lý các sự kiện xác thực người dùng.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<FetchProfile>(_onFetchProfile);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.login(email: event.email, password: event.password);
      emit(AuthAuthenticated(user: user));
    } on AuthenticationException catch (e) {
      emit(AuthError(message: e.message));
      emit(const AuthUnauthenticated());
    } on AppException catch (e) {
      emit(AuthError(message: e.message));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.register(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user: user));
    } on ValidationException catch (e) {
      emit(AuthError(message: e.message));
      emit(const AuthUnauthenticated());
    } on AppException catch (e) {
      emit(AuthError(message: e.message));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await authRepository.logout();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.fetchProfile();
      emit(AuthAuthenticated(user: user));
    } on AppException {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onFetchProfile(FetchProfile event, Emitter<AuthState> emit) async {
    final previous = state;
    emit(AuthLoading());
    try {
      final user = await authRepository.fetchProfile();
      emit(AuthAuthenticated(user: user));
    } on AppException catch (e) {
      emit(AuthError(message: e.message));
      _restorePreviousState(previous, emit);
    }
  }

  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    final previous = state;
    emit(AuthLoading());
    try {
      final user = await authRepository.updateProfile(
        name: event.name,
        phone: event.phone,
        address: event.address,
        gender: event.gender,
        dateOfBirth: event.dateOfBirth,
        studentClass: event.studentClass,
      );
      emit(AuthAuthenticated(user: user));
    } on ValidationException catch (e) {
      emit(AuthError(message: e.message));
      _restorePreviousState(previous, emit);
    } on AppException catch (e) {
      emit(AuthError(message: e.message));
      _restorePreviousState(previous, emit);
    }
  }

  void _restorePreviousState(AuthState previous, Emitter<AuthState> emit) {
    if (previous is AuthAuthenticated) {
      emit(previous);
    } else {
      emit(const AuthUnauthenticated());
    }
  }
}

