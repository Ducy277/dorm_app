import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/exceptions.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/repositories/notification_repository.dart';

part 'notification_event.dart';
part 'notification_state.dart';

/// Bloc xử lý thông báo.
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository notificationRepository;

  NotificationBloc({required this.notificationRepository}) : super(NotificationInitial()) {
    on<FetchNotifications>(_onFetchNotifications);
    on<FetchNotificationDetail>(_onFetchNotificationDetail);
  }

  Future<void> _onFetchNotifications(
    FetchNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final notifications = await notificationRepository.getNotifications(page: event.page);
      emit(NotificationsLoaded(notifications: notifications));
    } on AppException catch (e) {
      emit(NotificationError(message: e.message));
    }
  }

  Future<void> _onFetchNotificationDetail(
    FetchNotificationDetail event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final notification = await notificationRepository.getNotificationDetail(event.id);
      emit(NotificationLoaded(notification: notification));
    } on AppException catch (e) {
      emit(NotificationError(message: e.message));
    }
  }
}

