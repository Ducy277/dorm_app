part of 'notification_bloc.dart';

/// Sự kiện cho NotificationBloc.
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object?> get props => [];
}

class FetchNotifications extends NotificationEvent {
  final int? page;
  const FetchNotifications({this.page});
  @override
  List<Object?> get props => [page];
}

class MarkNotificationRead extends NotificationEvent {
  final int id;
  const MarkNotificationRead({required this.id});
  @override
  List<Object?> get props => [id];
}