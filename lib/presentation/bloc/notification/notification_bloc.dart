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
    on<MarkNotificationRead>(_onMarkAsRead);
  }

  Future<void> _onFetchNotifications(FetchNotifications event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    try {
      final notifications = await notificationRepository.getNotifications(page: event.page);
      emit(NotificationsLoaded(notifications: notifications));
    } on AppException catch (e) {
      emit(NotificationError(message: e.message));
    }
  }

  Future<void> _onMarkAsRead(MarkNotificationRead event, Emitter<NotificationState> emit) async {
    try {
      await notificationRepository.markAsRead(event.id);
      // Sau khi đánh dấu đọc, có thể refresh danh sách hoặc cập nhật cục bộ.
    } on AppException catch (e) {
      emit(NotificationError(message: e.message));
    }
  }
}