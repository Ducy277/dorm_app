import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/bill_repository.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/repositories/repair_repository.dart';
import '../../data/repositories/payment_repository.dart';
import '../../data/repositories/room_repository.dart';
import '../../data/repositories/review_repository.dart';
import '../../data/models/notification_model.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/bill/bill_bloc.dart';
import '../bloc/repair/repair_bloc.dart';
import '../bloc/room/room_bloc.dart';
import '../bloc/booking/booking_bloc.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/rooms/rooms_screen.dart';
import '../screens/rooms/room_detail_screen.dart';
import '../screens/bookings/bookings_screen.dart';
import '../screens/bookings/booking_request_screen.dart';
import '../screens/bookings/return_room_screen.dart';
import '../screens/bills/bill_detail_screen.dart';
import '../screens/bills/bills_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/notifications/notification_detail_screen.dart';
import '../screens/repairs/repair_request_screen.dart';
import '../screens/repairs/repairs_screen.dart';
import '../screens/profile/profile_screen.dart';

/// Định nghĩa router sử dụng GoRouter.
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'rooms',
            name: 'rooms',
            builder: (context, state) {
              return BlocProvider.value(
                value: context.read<RoomBloc>(),
                child: const RoomsScreen(),
              );
            },
            routes: [
              // Chi tiết phòng
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  final parentRoomBloc = context.read<RoomBloc>();
                  final favIds = <int>{};
                  final parentState = parentRoomBloc.state;
                  if (parentState is RoomsLoaded) {
                    favIds.addAll(
                      parentState.rooms.where((r) => r.isFavourite).map((r) => r.id),
                    );
                  }
                  return BlocProvider(
                    create: (context) => RoomBloc(
                      roomRepository: context.read<RoomRepository>(),
                      reviewRepository: context.read<ReviewRepository>(),
                      initialFavourites: favIds,
                    )..add(FetchRoomDetail(id: id)),
                    child: RoomDetailScreen(roomId: id),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: 'bookings',
            name: 'bookings',
            builder: (context, state) => const BookingsScreen(),
            routes: [
              GoRoute(
                path: 'request',
                builder: (context, state) {
                  final payload = state.extra is BookingRequestPayload
                      ? state.extra as BookingRequestPayload
                      : null;
                  return BookingRequestScreen(
                    initialType:
                        payload?.type ?? BookingRequestType.registration,
                    roomId: payload?.roomId,
                    roomCode: payload?.roomCode,
                  );
                },
              ),
              GoRoute(
                path: 'return',
                builder: (context, state) => BlocProvider(
                  create: (context) => BookingBloc(
                    bookingRepository: context.read<BookingRepository>(),
                  ),
                  child: const ReturnRoomScreen(),
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'bills',
            name: 'bills',
            builder: (context, state) => const BillsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return BlocProvider(
                    create: (context) => BillBloc(
                      billRepository: context.read<BillRepository>(),
                      paymentRepository: context.read<PaymentRepository>(),
                    ),
                    child: BillDetailScreen(billId: id),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: 'repairs',
            name: 'repairs',
            builder: (context, state) => const RepairsScreen(),
            routes: [
              GoRoute(
                path: 'request',
                builder: (context, state) => BlocProvider(
                  create: (context) => RepairBloc(
                    repairRepository: context.read<RepairRepository>(),
                  ),
                  child: const RepairRequestScreen(),
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'notifications',
            name: 'notifications',
            builder: (context, state) => const NotificationsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                name: 'notificationDetail',
                builder: (context, state) {
                  final id = int.tryParse(state.pathParameters['id'] ?? '');
                  final extra = state.extra;
                  return NotificationDetailScreen(
                    id: id,
                    notification: extra is NotificationModel ? extra : null,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: 'profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      final isAuthenticated = authState is AuthAuthenticated;
      final isGoingToLogin =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isAuthenticated && !isGoingToLogin) {
        return '/login';
      }

      if (isAuthenticated && isGoingToLogin) {
        return '/';
      }

      return null;
    },
  );
}
