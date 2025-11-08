import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/room_model.dart';
import '../bloc/room/room_bloc.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/rooms/room_form_create.dart';
import '../screens/rooms/room_images_screen.dart';
import '../screens/rooms/rooms_screen.dart';
import '../screens/rooms/room_detail_screen.dart';
import '../screens/bookings/bookings_screen.dart';
import '../screens/bills/bills_screen.dart';
import '../screens/repairs/repairs_screen.dart';
import '../screens/profile/profile_screen.dart';

/// Định nghĩa router sử dụng GoRouter.
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
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
              // Tạo phòng mới
              GoRoute(
                path: 'create',
                builder: (context, state) {
                  return BlocProvider.value(
                    value: context.read<RoomBloc>(),
                    child: const RoomFormScreen(),
                  );
                },
              ),
              // Chỉnh sửa phòng
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) {
                  final room = state.extra as RoomModel;
                  return BlocProvider.value(
                    value: context.read<RoomBloc>(),
                    child: RoomFormScreen(room: room),
                  );
                },
              ),

              // Chi tiết phòng
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return BlocProvider.value(
                    value: context.read<RoomBloc>(),
                    child: RoomDetailScreen(roomId: id),
                  );
                },
              ),

              // Upload ảnh phòng
              GoRoute(
                path: ':id/images',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return BlocProvider.value(
                    value: context.read<RoomBloc>(),
                    child: RoomImagesScreen(roomId: id),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: 'bookings',
            name: 'bookings',
            builder: (context, state) => const BookingsScreen(),
          ),
          GoRoute(
            path: 'bills',
            name: 'bills',
            builder: (context, state) => const BillsScreen(),
          ),
          GoRoute(
            path: 'repairs',
            name: 'repairs',
            builder: (context, state) => const RepairsScreen(),
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
      // Chặn truy cập nếu chưa đăng nhập; simple check via AuthBloc state
      // Cần đọc trạng thái AuthBloc để điều hướng. Ở đây tạm thời bỏ qua.
      return null;
    },
  );
}