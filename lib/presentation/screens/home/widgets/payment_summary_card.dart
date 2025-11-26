import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../domain/entities/booking_entity.dart';
import '../../../../domain/entities/bill_entity.dart';
import '../../../../domain/entities/service_entity.dart';
import '../../../bloc/bill/bill_bloc.dart';

class PaymentSummaryCard extends StatelessWidget {
  final BookingEntity? activeBooking;
  final BillState billState;
  final VoidCallback onPrimaryAction;
  final VoidCallback onSecondaryAction;

  const PaymentSummaryCard({
    super.key,
    required this.activeBooking,
    required this.billState,
    required this.onPrimaryAction,
    required this.onSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    if (activeBooking == null) {
      return CustomCard(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dịch vụ & thanh toán', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Bạn chưa đăng ký phòng. Khám phá danh sách phòng ngay!',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            CustomButton(
              label: 'Xem danh sách phòng',
              onPressed: onSecondaryAction,
              icon: Icons.meeting_room_outlined,
            ),
          ],
        ),
      );
    }

    final room = activeBooking!.room;
    final roomPrice = room?.pricePerMonth;
    final services = room?.services ?? <ServiceEntity>[];
    final billSummary = _readBill(billState);

    return CustomCard(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Dịch vụ & thanh toán', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              if (billSummary.statusLabel != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: billSummary.statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    billSummary.statusLabel!,
                    style: TextStyle(
                      color: billSummary.statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          if (room != null) ...[
            Text(
              'Phòng ${room.roomCode}${room.branchName != null ? ' • ${room.branchName}' : ''}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              '${room.capacity} người • ${room.genderType ?? 'Không rõ'}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
            ),
          ],
          const SizedBox(height: AppSizes.paddingMedium),
          _ServiceLine(
            icon: Icons.attach_money_rounded,
            label: 'Giá phòng / tháng',
            value: roomPrice != null ? '${roomPrice.toStringAsFixed(0)} đ' : 'Chưa rõ',
          ),
          ...services.take(3).map(
                (service) => _ServiceLine(
              icon: _serviceIcon(service.name),
              label: service.name,
              value: '${service.unitPrice.toStringAsFixed(0)} đ/${service.unit}',
              color: _serviceColor(service.name),
            ),
          ),
          if (services.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '+${services.length - 3} dịch vụ khác',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
              ),
            ),
          const SizedBox(height: AppSizes.paddingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (billSummary.daysUntilDue != null)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _DuePill(days: billSummary.daysUntilDue!),
                ),
              CustomButton(
                label: 'Xem hóa đơn',
                onPressed: onPrimaryAction,
                icon: Icons.receipt_long_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  _BillSummary _readBill(BillState state) {
    if (state is BillsLoaded && state.bills.isNotEmpty) {
      final bill = state.bills.first;
      return _BillSummary(
        statusLabel: bill.status == 'paid' ? 'Đã thanh toán' : 'Chưa thanh toán',
        statusColor: bill.status == 'paid' ? const Color(0xFF2E7D32) : AppColors.primary,
        daysUntilDue: _calculateDaysUntil(bill.dueDate),
      );
    }
    if (state is BillLoading) {
      return const _BillSummary(statusLabel: 'Loading...', statusColor: AppColors.primary);
    }
    return const _BillSummary(statusLabel: null, statusColor: AppColors.primary);
  }

  int? _calculateDaysUntil(String? dueDate) {
    if (dueDate == null) return null;
    try {
      final due = DateTime.parse(dueDate);
      final now = DateTime.now();
      return due.difference(now).inDays;
    } catch (_) {
      return null;
    }
  }

  IconData _serviceIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('nước') || lower.contains('nuoc')) {
      return Icons.water_drop_outlined;
    }
    if (lower.contains('internet') || lower.contains('wifi')) {
      return Icons.wifi_tethering_outlined;
    }
    if (lower.contains('điện') || lower.contains('dien') || lower.contains('electric')) {
      return Icons.bolt_outlined;
    }
    return Icons.miscellaneous_services_outlined;
  }

  Color _serviceColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('nước') || lower.contains('nuoc')) {
      return const Color(0xFF03A9F4);
    }
    if (lower.contains('internet') || lower.contains('wifi')) {
      return const Color(0xFF7C4DFF);
    }
    if (lower.contains('điện') || lower.contains('dien') || lower.contains('electric')) {
      return const Color(0xFFFF9800);
    }
    return AppColors.primaryDark;
  }
}

class _ServiceLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ServiceLine({
    required this.icon,
    required this.label,
    required this.value,
    this.color = AppColors.primaryDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF1F2430),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DuePill extends StatelessWidget {
  final int days;
  const _DuePill({required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            days >= 0 ? 'Còn $days ngày' : 'Quá hạn ${days.abs()} ngày',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BillSummary {
  final String? statusLabel;
  final Color statusColor;
  final int? daysUntilDue;

  const _BillSummary({
    required this.statusLabel,
    required this.statusColor,
    this.daysUntilDue,
  });
}
