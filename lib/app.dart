import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/secure_storage.dart';
import 'data/datasources/api_service.dart';
import 'data/repositories/auth_repository.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/routes/app_router.dart';
import 'data/repositories/room_repository.dart';
import 'data/repositories/booking_repository.dart';
import 'data/repositories/bill_repository.dart';
import 'data/repositories/payment_repository.dart';
import 'data/repositories/repair_repository.dart';
import 'data/repositories/review_repository.dart';
import 'data/repositories/notification_repository.dart';
import 'data/repositories/profile_repository.dart';
import 'presentation/bloc/room/room_bloc.dart';
import 'presentation/bloc/booking/booking_bloc.dart';
import 'presentation/bloc/bill/bill_bloc.dart';
import 'presentation/bloc/repair/repair_bloc.dart';
import 'presentation/bloc/notification/notification_bloc.dart';
import 'presentation/bloc/my_room/my_room_bloc.dart';

/// [QLKTXApp] là root widget của ứng dụng quản lý ký túc xá.
class QLKTXApp extends StatelessWidget {
  const QLKTXApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Khởi tạo các lớp dùng chung như ApiService, AuthRepository...
    final secureStorage = SecureStorage();
    final apiService = ApiService(secureStorage: secureStorage);
    final authRepository = AuthRepository(apiService: apiService, secureStorage: secureStorage);

    // Khởi tạo các repository khác
    final roomRepository = RoomRepository(apiService: apiService);
    final bookingRepository = BookingRepository(apiService: apiService);
    final billRepository = BillRepository(apiService: apiService);
    final paymentRepository = PaymentRepository(apiService: apiService);
    final repairRepository = RepairRepository(apiService: apiService);
    final notificationRepository = NotificationRepository(apiService: apiService);
    final profileRepository = ProfileRepository(apiService: apiService);
    final reviewRepository = ReviewRepository(apiService: apiService);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: roomRepository),
        RepositoryProvider.value(value: bookingRepository),
        RepositoryProvider.value(value: billRepository),
        RepositoryProvider.value(value: paymentRepository),
        RepositoryProvider.value(value: repairRepository),
        RepositoryProvider.value(value: notificationRepository),
        RepositoryProvider.value(value: profileRepository),
        RepositoryProvider.value(value: reviewRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc(authRepository: authRepository),
          ),
          BlocProvider<RoomBloc>(
            create: (_) => RoomBloc(roomRepository: roomRepository, reviewRepository: reviewRepository),
          ),
          BlocProvider<BookingBloc>(
            create: (_) => BookingBloc(bookingRepository: bookingRepository),
          ),
          BlocProvider<BillBloc>(
            create: (_) => BillBloc(
              billRepository: billRepository,
              paymentRepository: paymentRepository,
            ),
          ),
          BlocProvider<RepairBloc>(
            create: (_) => RepairBloc(repairRepository: repairRepository),
          ),
          BlocProvider<NotificationBloc>(
            create: (_) => NotificationBloc(notificationRepository: notificationRepository),
          ),
          BlocProvider<MyRoomBloc>(
            create: (_) => MyRoomBloc(roomRepository: roomRepository),
          ),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'QL Ký túc xá',
          theme: AppTheme.lightTheme,
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
