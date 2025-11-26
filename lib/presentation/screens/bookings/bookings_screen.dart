import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../data/models/booking_model.dart';
import '../../bloc/booking/booking_bloc.dart';

/// Màn hình danh sách các đơn đặt phòng
class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  bool _hasLoaded = false;
  String _statusFilter = 'all';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded) {
      context.read<BookingBloc>().add(const FetchBookings());
      _hasLoaded = true;
    }
  }

  Future<void> _refresh() async {
    context.read<BookingBloc>().add(const FetchBookings());
  }

  Future<void> _openRequestForm() async {
    final created = await context.push<bool>('/bookings/request');
    if (created == true && mounted) {
      _refresh();
    }
  }

  List<BookingModel> _applyFilter(List<BookingModel> bookings) {
    if (_statusFilter == 'all') return bookings;
    return bookings
        .where((b) => b.status.toLowerCase() == _statusFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đơn đặt phòng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _openRequestForm,
          ),
        ],
      ),
      body: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          if (state is BookingLoading) {
            return const LoadingIndicator();
          } else if (state is BookingError) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: [
                  const SizedBox(height: 160),
                  Center(child: Text('Lỗi: ${state.message}')),
                ],
              ),
            );
          } else if (state is BookingsLoaded) {
            final filtered = _applyFilter(state.bookings);
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                children: [
                  _StatusFilters(
                    selected: _statusFilter,
                    onChanged: (value) => setState(() => _statusFilter = value),
                    available: _uniqueStatuses(state.bookings),
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  if (filtered.isEmpty)
                    const _EmptyBookings()
                  else
                    ...filtered.map((b) => _BookingCard(booking: b)),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  List<String> _uniqueStatuses(List<BookingModel> bookings) {
    final statuses = bookings.map((e) => e.status.toLowerCase()).toSet().toList();
    statuses.sort();
    return statuses;
  }
}

class _StatusFilters extends StatelessWidget {
  final String selected;
  final void Function(String value) onChanged;
  final List<String> available;

  const _StatusFilters({
    required this.selected,
    required this.onChanged,
    required this.available,
  });

  @override
  Widget build(BuildContext context) {
    final filters = ['all', ...available];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: filters.map((status) {
        return ChoiceChip(
          label: Text(_label(status)),
          selected: selected == status,
          onSelected: (_) => onChanged(status),
        );
      }).toList(),
    );
  }

  String _label(String status) {
    switch (status) {
      case 'active':
        return 'Đang hoạt động';
      case 'pending':
        return 'Đang chờ duyệt';
      case 'approved':
        return 'Đã duyệt';
      case 'rejected':
        return 'Đã từ chối';
      case 'expired':
        return 'Hết hạn';
      case 'all':
      default:
        return 'Tất cả';
    }
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  const _BookingCard({required this.booking});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF2E7D32);
      case 'pending':
        return const Color(0xFFFFA000);
      case 'approved':
        return AppColors.primary;
      case 'rejected':
      case 'cancelled':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Đang hoạt động';
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
    final room = booking.room;
    final branch = room?.branchName ?? '';
    final roomName = room != null ? 'Phòng ${room.roomCode}' : 'Chưa có phòng';
    final requestedCheckout = booking.status.toLowerCase() == 'active' &&
        booking.actualCheckOutDate != null &&
        booking.actualCheckOutDate!.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(roomName, style: Theme.of(context).textTheme.titleMedium),
                    if (branch.isNotEmpty)
                      Text(
                        branch,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                      ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor(booking.status).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _statusLabel(booking.status),
                    style: TextStyle(
                      color: _statusColor(booking.status),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.category_outlined, size: 18, color: Colors.black54),
                const SizedBox(width: 6),
                Text(_bookingTypeLabel(booking.bookingType)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.login_outlined, size: 18, color: Colors.black54),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Nhận phòng: ${booking.checkInDate}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.logout_outlined, size: 18, color: Colors.black54),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Trả phòng dự kiến: ${booking.expectedCheckOutDate}',
                  ),
                ),
              ],
            ),
            if (requestedCheckout) ...[
              const SizedBox(height: 4),
              Row(
                children: const [
                  Icon(Icons.logout, size: 18, color: Colors.redAccent),
                  SizedBox(width: 6),
                  Text('Đã gửi yêu cầu trả phòng',
                      style: TextStyle(color: Colors.redAccent)),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.assignment_outlined, size: 18, color: Colors.black54),
                const SizedBox(width: 6),
                Text('Hình thức thuê: ${booking.rentalType}'),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _showDetail(context, booking),
                icon: const Icon(Icons.chevron_right),
                label: const Text('Chi tiết'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _bookingTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'registration':
        return 'Đăng ký mới';
      case 'extension':
        return 'Gia hạn';
      case 'transfer':
        return 'Đổi phòng';
      default:
        return type;
    }
  }

  void _showDetail(BuildContext context, BookingModel booking) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        final room = booking.room;
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Chi tiết đơn', style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _statusColor(booking.status).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _statusLabel(booking.status),
                      style: TextStyle(color: _statusColor(booking.status), fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (room != null) ...[
                Text('Phòng: ${room.roomCode}'),
                if (room.branchName != null) Text('Chi nhánh: ${room.branchName}'),
              ],
              const SizedBox(height: 8),
              Text('Loại: ${_bookingTypeLabel(booking.bookingType)}'),
              Text('Nhận phòng: ${booking.checkInDate}'),
              Text('Trả phòng dự kiến: ${booking.expectedCheckOutDate}'),
              Text('Hình thức thuê: ${booking.rentalType}'),
              if (booking.actualCheckOutDate != null &&
                  booking.actualCheckOutDate!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Trả phòng thực tế: ${booking.actualCheckOutDate}'),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  TextButton(
                    onPressed: room != null ? () => context.push('/rooms/${room.id}') : null,
                    child: const Text('Xem phòng'),
                  ),
                  const Spacer(),
                  if (_canCancel(booking))
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<BookingBloc>().add(CancelBookingEvent(booking.id));
                        context.read<BookingBloc>().add(const FetchBookings());
                      },
                      child: const Text('Huỷ yêu cầu'),
                    ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Đóng'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  bool _canCancel(BookingModel booking) {
    if (booking.status.toLowerCase() != 'pending') return false;
    final type = booking.bookingType.toLowerCase();
    return type == 'registration' || type == 'extension' || type == 'transfer';
  }
}

class _EmptyBookings extends StatelessWidget {
  const _EmptyBookings();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 120),
        const Icon(Icons.assignment_outlined, size: 72, color: Colors.grey),
        const SizedBox(height: 12),
        Text('Bạn chưa có đơn đặt phòng', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(
          'Tạo đơn đặt phòng mới để bắt đầu kỳ thuê.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
        ),
      ],
    );
  }
}
