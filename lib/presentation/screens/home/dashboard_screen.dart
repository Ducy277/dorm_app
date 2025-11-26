import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/bill/bill_bloc.dart';
import '../../bloc/my_room/my_room_bloc.dart';
import '../../bloc/notification/notification_bloc.dart';
import 'widgets/alert_card.dart';
import 'widgets/header_section.dart';
import 'widgets/sidebar_drawer.dart';
import 'widgets/payment_summary_card.dart';
import 'widgets/quick_actions.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _initialized = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _refreshAll();
      _initialized = true;
    }
  }

  Future<void> _refreshAll() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<AuthBloc>().add(const FetchProfile());
      context.read<MyRoomBloc>().add(MyRoomRequested(userId: authState.user.id));
      context.read<NotificationBloc>().add(const FetchNotifications());
      context.read<BillBloc>().add(const FetchBills());
    }
  }

  void _requireLogin() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bạn cần đăng nhập để sử dụng chức năng này.')),
    );
    context.go('/login');
  }

  void _requireActiveRoom() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bạn chưa có phòng hoặc booking đang hoạt động.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isAuthenticated = authState is AuthAuthenticated;
    final notificationCount = context.select<NotificationBloc, int>((bloc) {
      final state = bloc.state;
      if (state is NotificationsLoaded) return state.notifications.length;
      return 0;
    });

    return Scaffold(
      key: _scaffoldKey,
      drawer: SidebarDrawer(onNavigate: (route) {
        Navigator.pop(context);
        context.go(route);
      }),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshAll,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              BlocBuilder<MyRoomBloc, MyRoomState>(
                builder: (context, myRoomState) {
                  final activeBooking = myRoomState is MyRoomLoaded ? myRoomState.activeBooking : null;
                  return HeaderSection(
                    userName: isAuthenticated ? (authState as AuthAuthenticated).user.name : 'Bạn',
                    activeBooking: activeBooking,
                    notificationCount: notificationCount,
                    onAvatarTap: () => _scaffoldKey.currentState?.openDrawer(),
                    onNotificationTap: () {
                      if (!isAuthenticated) {
                        _requireLogin();
                        return;
                      }
                      context.go('/notifications');
                    },
                  );
                },
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
                child: BlocBuilder<NotificationBloc, NotificationState>(
                  builder: (context, state) {
                    if (!isAuthenticated) {
                      return const SizedBox.shrink();
                    }
                    if (state is NotificationLoading) {
                      return const QuickNotificationShimmer();
                    }
                    if (state is NotificationsLoaded && state.notifications.isNotEmpty) {
                      final sorted = [...state.notifications]
                        ..sort((a, b) {
                          final aDate = DateTime.tryParse(a.createdAt);
                          final bDate = DateTime.tryParse(b.createdAt);
                          if (aDate != null && bDate != null) {
                            return bDate.compareTo(aDate);
                          }
                          return b.createdAt.compareTo(a.createdAt);
                        });
                      final items = sorted.take(3).toList();
                      return QuickNotifications(
                        notifications: items,
                        onTap: (id) => context.go('/notifications/$id'),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              const SizedBox(height: AppSizes.paddingLarge),
              BlocBuilder<MyRoomBloc, MyRoomState>(
                builder: (context, myRoomState) {
                  final activeBooking = myRoomState is MyRoomLoaded ? myRoomState.activeBooking : null;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
                    child: HomeQuickActions(
                      isAuthenticated: isAuthenticated,
                      hasActiveRoom: activeBooking != null,
                      onRequireLogin: _requireLogin,
                      onRequireActiveRoom: _requireActiveRoom,
                      onNavigate: (route) => context.go(route),
                      activeBooking: activeBooking,
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
                child: BlocBuilder<MyRoomBloc, MyRoomState>(
                  builder: (context, myRoomState) {
                    final activeBooking = myRoomState is MyRoomLoaded ? myRoomState.activeBooking : null;
                    return BlocBuilder<BillBloc, BillState>(
                      builder: (context, billState) {
                        return PaymentSummaryCard(
                          activeBooking: activeBooking,
                          billState: billState,
                          onPrimaryAction: () {
                            if (!isAuthenticated) {
                              _requireLogin();
                              return;
                            }
                            if (activeBooking == null) {
                              context.go('/rooms');
                              return;
                            }
                            context.go('/bills');
                          },
                          onSecondaryAction: () => context.go('/rooms'),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSizes.paddingLarge),
            ],
          ),
        ),
      ),
    );
  }
}
