part of 'notification_bloc.dart';

/// Trạng thái cho NotificationBloc.
abstract class NotificationState extends Equatable {
  const NotificationState();
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationsLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  const NotificationsLoaded({required this.notifications});
  @override
  List<Object?> get props => [notifications];
}

class NotificationLoaded extends NotificationState {
  final NotificationModel notification;
  const NotificationLoaded({required this.notification});
  @override
  List<Object?> get props => [notification];
}

class NotificationError extends NotificationState {
  final String message;
  const NotificationError({required this.message});
  @override
  List<Object?> get props => [message];
}
