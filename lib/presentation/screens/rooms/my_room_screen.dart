import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../domain/entities/booking_entity.dart';
import '../../../domain/entities/room_entity.dart';
import '../../../domain/entities/roommate_entity.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/my_room/my_room_bloc.dart';

class MyRoomScreen extends StatefulWidget {
  const MyRoomScreen({super.key});

  @override
  State<MyRoomScreen> createState() => _MyRoomScreenState();
}

class _MyRoomScreenState extends State<MyRoomScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      final authState = context.read<AuthBloc>().state;
      final userId = authState is AuthAuthenticated ? authState.user.id : null;
      context.read<MyRoomBloc>().add(MyRoomRequested(userId: userId));
      _loaded = true;
    }
  }

  Future<void> _refresh() async {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : null;
    context.read<MyRoomBloc>().add(MyRoomRequested(userId: userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phòng của tôi')),
      body: BlocBuilder<MyRoomBloc, MyRoomState>(
        builder: (context, state) {
          if (state is MyRoomLoading) {
            return const LoadingIndicator();
          }
          if (state is MyRoomError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    CustomButton(
                      label: 'Thử lại',
                      onPressed: _refresh,
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is MyRoomEmpty) {
            return _EmptyMyRoom(onViewRooms: () => context.go('/rooms'));
          }
          if (state is MyRoomLoaded) {
            final booking = state.activeBooking;
            final room = state.room;
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                children: [
                  if (booking != null) ...[
                    _OverviewCard(booking: booking, room: room),
                    const SizedBox(height: 16),
                  ],
                  _RoomInfoSection(room: room),
                  const SizedBox(height: 16),
                  _AmenitiesSection(room: room),
                  const SizedBox(height: 16),
                  _ServicesSection(room: room),
                  const SizedBox(height: 16),
                  _RoommatesSection(roommates: state.roommates),
                  const SizedBox(height: 16),
                  const _RecentActivitySection(),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _EmptyMyRoom extends StatelessWidget {
  final VoidCallback onViewRooms;
  const _EmptyMyRoom({required this.onViewRooms});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.meeting_room_outlined, size: 72, color: Colors.grey),
            const SizedBox(height: 12),
            Text('Bạn chưa đăng ký phòng', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Khám phá danh sách phòng phù hợp và đăng ký ngay.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            CustomButton(label: 'Xem danh sách phòng', onPressed: onViewRooms),
          ],
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final BookingEntity booking;
  final RoomEntity room;
  const _OverviewCard({required this.booking, required this.room});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF2E7D32);
      case 'pending':
        return const Color(0xFFFFA000);
      case 'rejected':
      case 'cancelled':
        return Colors.redAccent;
      default:
        return AppColors.primary;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Đang ở';
      case 'pending':
        return 'Đang chờ duyệt';
      case 'approved':
        return 'Đã duyệt';
      case 'rejected':
        return 'Đã từ chối';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(booking.status);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            SizedBox(
              height: 180,
              child: room.images.isNotEmpty
                  ? Image.network(
                room.images.first,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => const _HeroPlaceholder(),
              )
                  : const _HeroPlaceholder(),
            ),
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.05),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Phòng ${room.roomCode}',
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (room.branchName != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white70),
                          ),
                          child: Text(
                            room.branchName!,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _statusLabel(booking.status),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Từ ${booking.checkInDate} • Kỳ hạn: ${booking.expectedCheckOutDate}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomInfoSection extends StatelessWidget {
  final RoomEntity room;
  const _RoomInfoSection({required this.room});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Thông tin phòng', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              _InfoPill(icon: Icons.location_city_outlined, label: room.branchName ?? 'Chi nhánh chưa rõ'),
              const SizedBox(width: 8),
              _InfoPill(icon: Icons.layers_outlined, label: 'Tầng ${room.floorName ?? '-'}'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _InfoPill(icon: Icons.people_alt_outlined, label: 'Sức chứa ${room.capacity}'),
              const SizedBox(width: 8),
              _InfoPill(icon: Icons.person_outline, label: room.genderType ?? 'Không rõ'),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            room.description?.isNotEmpty == true ? room.description! : 'Chưa có mô tả ngắn.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _AmenitiesSection extends StatelessWidget {
  final RoomEntity room;
  const _AmenitiesSection({required this.room});

  @override
  Widget build(BuildContext context) {
    final amenities = room.amenities;
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tiện nghi', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          if (amenities.isEmpty)
            Text('Chưa có danh sách tiện nghi.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54))
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: amenities.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3.8,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final a = amenities[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          a.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _ServicesSection extends StatelessWidget {
  final RoomEntity room;
  const _ServicesSection({required this.room});

  @override
  Widget build(BuildContext context) {
    final services = room.services;
    return Column(
      children: [
        CustomCard(
          child: Row(
            children: [
              const Icon(Icons.payments_outlined, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Giá phòng / tháng', style: Theme.of(context).textTheme.bodySmall),
                    Text(
                      '${room.pricePerMonth.toStringAsFixed(0)} đ',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dịch vụ', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              if (services.isEmpty)
                Text('Chưa có dịch vụ đi kèm.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54))
              else
                Column(
                  children: services
                      .map(
                        (s) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.bolt_outlined),
                      title: Text(s.name),
                      subtitle: Text('${s.unitPrice.toStringAsFixed(0)} đ/${s.unit}'),
                      trailing: s.isMandatory
                          ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('Bắt buộc',
                            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                      )
                          : null,
                    ),
                  )
                      .toList(),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection();

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hoạt động gần đây', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Chưa có dữ liệu hoạt động.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _RoommatesSection extends StatelessWidget {
  final List<RoommateEntity> roommates;
  const _RoommatesSection({required this.roommates});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bạn cùng phòng', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (roommates.isEmpty)
            Text(
              'Chưa có danh sách bạn cùng phòng.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            )
          else
            Column(
              children: roommates
                  .map(
                    (rm) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(rm.name.isNotEmpty ? rm.name[0].toUpperCase() : '?'),
                  ),
                  title: Text(rm.name),
                  subtitle: Text([
                    if (rm.studentCode != null && rm.studentCode!.isNotEmpty) rm.studentCode!,
                    if (rm.email.isNotEmpty) rm.email,
                  ].join(' • ')),
                ),
              )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}

class _HeroPlaceholder extends StatelessWidget {
  const _HeroPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.heroBlue),
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: Colors.white, size: 42),
    );
  }
}
