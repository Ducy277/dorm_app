import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../data/models/room_model.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/my_room/my_room_bloc.dart';
import '../../bloc/room/room_bloc.dart';
import '../bookings/booking_request_screen.dart';

/// Màn hình chi tiết phòng.
class RoomDetailScreen extends StatefulWidget {
  final int? roomId;
  const RoomDetailScreen({super.key, required this.roomId});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  bool _myRoomRequested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authState = context.read<AuthBloc>().state;
    if (!_myRoomRequested && authState is AuthAuthenticated) {
      context
          .read<MyRoomBloc>()
          .add(MyRoomRequested(userId: authState.user.id));
      _myRoomRequested = true;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _refreshDetail() {
    if (widget.roomId != null) {
      context.read<RoomBloc>().add(FetchRoomDetail(id: widget.roomId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết phòng'),
        actions: [
          BlocBuilder<RoomBloc, RoomState>(
            builder: (context, state) {
              RoomModel? room;
              if (state is RoomLoaded) room = state.room;
              final isFavourite = room?.isFavourite == true;
              return IconButton(
                icon: Icon(isFavourite ? Icons.favorite : Icons.favorite_border, color: isFavourite ? Colors.redAccent : null),
                onPressed: room == null
                    ? null
                    : () => context.read<RoomBloc>().add(ToggleFavouriteRoom(room!.id)),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<RoomBloc, RoomState>(
        builder: (context, state) {
          if (state is RoomLoading) {
            return const LoadingIndicator();
          } else if (state is RoomLoaded) {
            return RefreshIndicator(
              onRefresh: () async => _refreshDetail(),
              child: _RoomDetailBody(room: state.room),
            );
          } else if (state is RoomError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _refreshDetail,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _RoomDetailBody extends StatelessWidget {
  final RoomModel room;
  const _RoomDetailBody({required this.room});

  double _rating() {
    if (room.reviews.isEmpty) return 0;
    final total = room.reviews.map((e) => e.rating).fold<int>(0, (a, b) => a + b);
    return total / room.reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    final rating = _rating();
    final hasReviews = room.reviews.isNotEmpty;
    final infoLine = [
      if (room.floorName != null) 'Tầng ${room.floorName}',
      '${room.capacity} người',
      room.genderType ?? 'Không rõ',
    ].join(' • ');

    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.zero,
          children: [
            _HeroHeader(room: room, rating: rating),
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Phòng ${room.roomCode}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    room.branchName ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    infoLine,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  _InfoGrid(room: room),
                  const SizedBox(height: 20),
                  _Section(
                    title: 'Mô tả phòng',
                    child: Text(
                      room.description?.isNotEmpty == true
                          ? room.description!
                          : 'Chưa có mô tả cho phòng này.',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Section(
                    title: 'Tiện nghi',
                    child: _AmenityGrid(amenities: room.amenities),
                  ),
                  const SizedBox(height: 16),
                  _Section(
                    title: 'Dịch vụ & giá',
                    child: _ServicesList(services: room.services),
                  ),
                  const SizedBox(height: 16),
                  _ReviewSection(room: room, rating: rating, hasReviews: hasReviews),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _BottomCTA(room: room),
        ),
      ],
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final RoomModel room;
  final double rating;
  const _HeroHeader({required this.room, required this.rating});

  String _statusText() {
    if (room.availableSlots <= 0) return 'Đầy';
    if (room.availableSlots <= 1) return 'Sắp đầy';
    return 'Còn chỗ';
  }

  Color _statusColor() {
    if (room.availableSlots <= 0) return Colors.redAccent;
    if (room.availableSlots <= 1) return const Color(0xFFFF9800);
    return const Color(0xFF2E7D32);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      child: SizedBox(
        height: 240,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (room.images.isNotEmpty)
              Image.network(
                room.images.first,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _HeroPlaceholder(),
              )
            else
              const _HeroPlaceholder(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.05),
                    Colors.black.withOpacity(0.65),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              bottom: 28,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          room.roomCode,
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
                            color: Colors.white.withOpacity(0.18),
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: _statusColor(),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _statusText(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        rating > 0 ? rating.toStringAsFixed(1) : 'Chưa có đánh giá',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ],
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

class _InfoGrid extends StatelessWidget {
  final RoomModel room;
  const _InfoGrid({required this.room});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _InfoTile(
            icon: Icons.payments_outlined,
            label: 'Giá tháng',
            value: '${room.pricePerMonth.toStringAsFixed(0)} đ',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _InfoTile(
            icon: Icons.people_alt_outlined,
            label: 'Sức chứa',
            value: '${room.capacity} người',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _InfoTile(
            icon: Icons.event_available_outlined,
            label: 'Chỗ trống',
            value: room.availableSlots > 0 ? '${room.availableSlots}' : 'Đầy',
            valueColor: room.availableSlots > 0 ? AppColors.primary : Colors.redAccent,
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: valueColor ?? const Color(0xFF1F2430),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewSection extends StatefulWidget {
  final RoomModel room;
  final double rating;
  final bool hasReviews;
  const _ReviewSection({
    required this.room,
    required this.rating,
    required this.hasReviews,
  });

  @override
  State<_ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<_ReviewSection> {
  int _selectedRating = 5;
  final TextEditingController _commentCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  void _submitReview() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn cần đăng nhập để đánh giá.')),
      );
      context.go('/login');
      return;
    }
    final comment = _commentCtrl.text.trim();
    if (_submitting) return;
    setState(() => _submitting = true);
    context.read<RoomBloc>().add(
      SubmitReview(widget.room.id, _selectedRating, comment),
    );
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() {
        _submitting = false;
        _commentCtrl.clear();
        _selectedRating = 5;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    return _Section(
      title: 'Đánh giá',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 6),
              Text(
                widget.rating > 0 ? widget.rating.toStringAsFixed(1) : 'Chưa có đánh giá',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (widget.hasReviews)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    '(${room.reviews.length})',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (widget.hasReviews)
            Column(
              children: room.reviews.take(3).map((r) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    child: Text(
                      (r.userName?.isNotEmpty == true ? r.userName![0] : '?').toUpperCase(),
                    ),
                  ),
                  title: Text(r.userName ?? 'Người dùng'),
                  subtitle: Text(r.comment ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      5,
                          (index) => Icon(
                        index < r.rating ? Icons.star : Icons.star_border,
                        size: 16,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                );
              }).toList(),
            )
          else
            Text(
              'Chưa có đánh giá nào.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
          const SizedBox(height: 12),
          Text('Thêm đánh giá', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: List.generate(5, (index) {
              final star = index + 1;
              return ChoiceChip(
                label: Text('$star ★'),
                selected: _selectedRating == star,
                onSelected: (_) => setState(() => _selectedRating = star),
              );
            }),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _commentCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Chia sẻ trải nghiệm của bạn...',
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: CustomButton(
              label: _submitting ? 'Đang gửi...' : 'Gửi đánh giá',
              onPressed: _submitReview,
              isLoading: _submitting,
              icon: Icons.send,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmenityGrid extends StatelessWidget {
  final List amenities;
  const _AmenityGrid({required this.amenities});

  @override
  Widget build(BuildContext context) {
    if (amenities.isEmpty) {
      return Text(
        'Chưa có danh sách tiện nghi.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
      );
    }
    return GridView.builder(
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
        final amenity = amenities[index];
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
                  amenity.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ServicesList extends StatelessWidget {
  final List services;
  const _ServicesList({required this.services});

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return Text(
        'Không có dịch vụ đi kèm.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
      );
    }
    return Column(
      children: services
          .map(
            (service) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.bolt_outlined),
          title: Text(service.name),
          subtitle: Text('${service.unitPrice.toStringAsFixed(0)} đ/${service.unit}'),
          trailing: service.isMandatory
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
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _BottomCTA extends StatelessWidget {
  final RoomModel room;
  const _BottomCTA({required this.room});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isAuthenticated = authState is AuthAuthenticated;
    final myRoomState = context.watch<MyRoomBloc>().state;
    final activeBooking =
    myRoomState is MyRoomLoaded ? myRoomState.activeBooking : null;
    final hasActive =
        activeBooking != null && activeBooking.status.toLowerCase() == 'active';

    void handleCTA() {
      if (!isAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bạn cần đăng nhập để đặt phòng.')),
        );
        context.go('/login');
        return;
      }

      final bookingType = hasActive ? BookingRequestType.transfer : BookingRequestType.registration;
      context.push(
        '/bookings/request',
        extra: BookingRequestPayload(
          type: bookingType,
          roomId: room.id,
          roomCode: room.roomCode,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${room.pricePerMonth.toStringAsFixed(0)} đ/th',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800),
              ),
              Text('Giá theo tháng', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const Spacer(),
          CustomButton(
            label: hasActive ? 'Đổi phòng' : 'Đăng ký phòng này',
            onPressed: handleCTA,
          ),
        ],
      ),
    );
  }
}
