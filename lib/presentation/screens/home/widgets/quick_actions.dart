import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../domain/entities/booking_entity.dart';

class HomeQuickActions extends StatefulWidget {
  final bool isAuthenticated;
  final bool hasActiveRoom;
  final BookingEntity? activeBooking;
  final VoidCallback onRequireLogin;
  final VoidCallback onRequireActiveRoom;
  final void Function(String route) onNavigate;

  const HomeQuickActions({
    super.key,
    required this.isAuthenticated,
    required this.hasActiveRoom,
    required this.activeBooking,
    required this.onRequireLogin,
    required this.onRequireActiveRoom,
    required this.onNavigate,
  });

  @override
  State<HomeQuickActions> createState() => _HomeQuickActionsState();
}

class _HomeQuickActionsState extends State<HomeQuickActions> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final actions = _buildActions();
    final totalPages = (actions.length / 6).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tiện ích nhanh', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSizes.paddingSmall),
        SizedBox(
          height: 280,
          child: PageView.builder(
            controller: _controller,
            itemCount: totalPages,
            onPageChanged: (index) => setState(() => _page = index),
            itemBuilder: (_, pageIndex) {
              final start = pageIndex * 6;
              final end = (start + 6).clamp(0, actions.length);
              final pageItems = actions.sublist(start, end);
              return GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: pageItems.map(_ActionItem.new).toList(),
              );
            },
          ),
        ),
        if (totalPages > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              totalPages,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 6,
                width: index == _page ? 18 : 6,
                decoration: BoxDecoration(
                  color: index == _page
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ]
      ],
    );
  }

  List<_ActionData> _buildActions() {
    final hasActive = widget.hasActiveRoom;
    return [
      _ActionData(
        icon: Icons.meeting_room_outlined,
        label: 'Xem phòng',
        color: AppColors.primary,
        onTap: () => widget.onNavigate('/rooms'),
      ),
      _ActionData(
        icon: Icons.article_outlined,
        label: 'Đơn đặt phòng',
        color: const Color(0xFF7C4DFF),
        requiresLogin: true,
        onTap: () => widget.onNavigate('/bookings'),
      ),
      _ActionData(
        icon: Icons.receipt_long_outlined,
        label: 'Hóa đơn',
        color: const Color(0xFF009688),
        requiresLogin: true,
        requiresActiveRoom: false,
        onTap: () => widget.onNavigate('/bills'),
      ),
      _ActionData(
        icon: Icons.build_circle_outlined,
        label: 'Sửa chữa',
        color: const Color(0xFFFF9800),
        requiresLogin: true,
        requiresActiveRoom: true,
        onTap: () => widget.onNavigate('/repairs'),
      ),
        _ActionData(
        icon: Icons.logout,
        label: 'Trả phòng',
        color: const Color(0xFF6D4C41),
        requiresLogin: true,
        requiresActiveRoom: true,
        onTap: () => widget.onNavigate('/bookings/return'),
        ),
    ].map((action) {
      final lockedLogin = action.requiresLogin && !widget.isAuthenticated;
      final lockedRoom = action.requiresActiveRoom && !hasActive;
      return action.copyWith(
        isLocked: lockedLogin || lockedRoom,
        lockReason: lockedLogin
            ? 'Cần đăng nhập'
            : lockedRoom
                ? 'Chưa có phòng'
                : null,
        onTap: () {
          if (lockedLogin) {
            widget.onRequireLogin();
            return;
          }
          if (lockedRoom) {
            widget.onRequireActiveRoom();
            return;
          }
          action.onTap?.call();
        },
      );
    }).toList();
  }
}

class _ActionItem extends StatelessWidget {
  final _ActionData data;
  const _ActionItem(this.data);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: data.isLocked ? null : data.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: data.isLocked ? Colors.white : AppColors.primary.withOpacity(0.02),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: data.isLocked ? Colors.black12 : data.color.withOpacity(0.18),
          ),
        ),
        padding: const EdgeInsets.all(AppSizes.paddingSmall - 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    data.color.withOpacity(0.12),
                    data.color.withOpacity(0.28),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(
                data.icon,
                color: data.isLocked ? Colors.grey : data.color,
                size: 26,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              data.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: data.isLocked ? Colors.grey : const Color(0xFF1F2430),
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (data.isLocked && data.lockReason != null) ...[
              const SizedBox(height: 4),
              Text(
                data.lockReason!,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionData {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool requiresLogin;
  final bool requiresActiveRoom;
  final bool isLocked;
  final String? lockReason;

  _ActionData({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
    this.requiresLogin = false,
    this.requiresActiveRoom = false,
    this.isLocked = false,
    this.lockReason,
  });

  _ActionData copyWith({
    bool? isLocked,
    String? lockReason,
    VoidCallback? onTap,
  }) {
    return _ActionData(
      icon: icon,
      label: label,
      color: color,
      requiresLogin: requiresLogin,
      requiresActiveRoom: requiresActiveRoom,
      onTap: onTap ?? this.onTap,
      isLocked: isLocked ?? this.isLocked,
      lockReason: lockReason ?? this.lockReason,
    );
  }
}
