import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../bloc/bill/bill_bloc.dart';
import '../../bloc/notification/notification_bloc.dart';
import 'widgets/alert_card.dart';
import 'widgets/header_section.dart';
import 'widgets/payment_summary_card.dart';
import 'widgets/quick_actions.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderSection(
                onAvatarTap: () => context.go('/profile'),
                onNotificationTap: () => context.go('/profile'),
              ),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: BlocBuilder<NotificationBloc, NotificationState>(
                  builder: (context, state) {
                    if (state is NotificationLoading) {
                      return const _ShimmerBox(height: 72);
                    }
                    if (state is NotificationsLoaded && state.notifications.isNotEmpty) {
                      final items = state.notifications.take(2).toList();
                      return Column(
                        children: [
                          AlertCard(
                            title: items[0].title,
                            description: items[0].content ?? '',
                            priority: AlertPriority.medium, // Assuming medium priority
                            onTap: () {},
                          ),
                          if (items.length > 1) ...[
                            const SizedBox(height: 8),
                            AlertCard(
                              title: items[1].title,
                              description: items[1].content ?? '',
                              priority: AlertPriority.low, // Assuming low priority
                              onTap: () {},
                            ),
                          ],
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),

              const SizedBox(height: 24),

              QuickActions(actions: [
                QuickAction(icon: Icons.meeting_room, label: AppStrings.rooms, color: Colors.blue, onTap: () => context.go('/rooms')),
                QuickAction(icon: Icons.assignment, label: AppStrings.bookings, color: Colors.pink, onTap: () => context.go('/bookings')),
                QuickAction(icon: Icons.receipt_long, label: AppStrings.bills, color: Colors.teal, onTap: () => context.go('/bills')),
                QuickAction(icon: Icons.build_circle_outlined, label: AppStrings.repairs, color: Colors.orange, onTap: () => context.go('/repairs')),
                QuickAction(icon: Icons.person_outline, label: AppStrings.profile, color: Colors.indigo, onTap: () => context.go('/profile')),
              ]),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: BlocBuilder<BillBloc, BillState>(
                  builder: (context, state) {
                    if (state is BillLoading) {
                      return const _ShimmerBox(height: 180);
                    }
                    if (state is BillsLoaded && state.bills.isNotEmpty) {
                      final latest = state.bills.first;
                      final items = (latest.billItems ?? [])
                          .map((e) => PaymentItem(label: e.description, value: e.amount, unit: 'đ'))
                          .toList();
                      return PaymentSummaryCard(
                        items: items,
                        daysUntilNextPayment: _calculateDaysUntil(latest.dueDate),
                        onPayTap: () => context.go('/bills'),
                      );
                    }
                    return PaymentSummaryCard(
                      items: const [],
                      daysUntilNextPayment: 0,
                      onPayTap: () => context.go('/bills'),
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  int _calculateDaysUntil(String? dueDate) {
    if (dueDate == null) return 0;
    try {
      final due = DateTime.parse(dueDate);
      final now = DateTime.now();
      return due.difference(now).inDays;
    } catch (_) {
      return 0;
    }
  }
}

class _ShimmerBox extends StatelessWidget {
  final double height;
  const _ShimmerBox({required this.height});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: Colors.black.withAlpha(12), borderRadius: BorderRadius.circular(12)),
    );
  }
}
