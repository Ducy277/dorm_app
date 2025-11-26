import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../data/models/bill_item_model.dart';
import '../../bloc/bill/bill_bloc.dart';

/// Màn hình danh sách các yêu cầu sửa chữa
class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  bool _hasLoaded = false;
  String _statusFilter = 'all';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded) {
      context.read<BillBloc>().add(const FetchBills());
      _hasLoaded = true;
    }
  }

  Future<void> _refresh() async {
    context.read<BillBloc>().add(const FetchBills());
  }

  List _filter(List bills) {
    if (_statusFilter == 'all') return bills;
    return bills.where((b) => b.status.toLowerCase() == _statusFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hóa đơn')),
      body: BlocBuilder<BillBloc, BillState>(
        builder: (context, state) {
          if (state is BillLoading) return const LoadingIndicator();
          if (state is BillError) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: [
                  const SizedBox(height: 160),
                  Center(child: Text('Lỗi: ${state.message}')),
                ],
              ),
            );
          }
          if (state is! BillsLoaded) return const SizedBox.shrink();

          final filtered = _filter(state.bills);
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              children: [
                _BillStatusFilter(
                  selected: _statusFilter,
                  onChanged: (v) => setState(() => _statusFilter = v),
                ),
                const SizedBox(height: AppSizes.paddingMedium),
                if (filtered.isEmpty)
                  const _EmptyBills()
                else
                  ...filtered.map((bill) => _BillCard(bill: bill)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BillStatusFilter extends StatelessWidget {
  final String selected;
  final void Function(String value) onChanged;
  const _BillStatusFilter({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const options = [
      ['all', 'Tất cả'],
      ['unpaid', 'Chưa thanh toán'],
      ['paid', 'Đã thanh toán'],
      ['overdue', 'Quá hạn'],
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options
          .map(
            (opt) => ChoiceChip(
          label: Text(opt[1]),
          selected: selected == opt[0],
          onSelected: (_) => onChanged(opt[0]),
        ),
      )
          .toList(),
    );
  }
}

class _BillCard extends StatelessWidget {
  final dynamic bill;
  const _BillCard({required this.bill});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return const Color(0xFF2E7D32);
      case 'overdue':
        return Colors.redAccent;
      default:
        return AppColors.primary;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'Đã thanh toán';
      case 'overdue':
        return 'Quá hạn';
      case 'unpaid':
      default:
        return 'Chưa thanh toán';
    }
  }

  String _title() {
    if (bill.dueDate != null && bill.dueDate!.length >= 7) {
      final monthYear = bill.dueDate!.substring(0, 7);
      return 'Hóa đơn tháng $monthYear';
    }
    return 'Hóa đơn #${bill.billCode}';
  }

  List<BillItemModel> _items() => bill.billItems ?? const <BillItemModel>[];

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(bill.status);
    final items = _items();
    final summary = items.take(3).map((i) => '${i.description}: ${i.amount.toStringAsFixed(0)}đ').join('\n');
    final branch = bill.booking?.room?.branchName;
    final roomCode = bill.booking?.room?.roomCode;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: CustomCard(
        onTap: () => context.go('/bills/${bill.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_title(), style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      if (roomCode != null)
                        Text(
                          'Phòng $roomCode${branch != null ? ' • $branch' : ''}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _statusLabel(bill.status),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (summary.isNotEmpty)
              Text(
                summary,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (bill.dueDate != null)
                      Text('Hạn: ${bill.dueDate}', style: Theme.of(context).textTheme.bodySmall),
                    TextButton(
                      onPressed: () => context.go('/bills/${bill.id}'),
                      child: const Text('Chi tiết'),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${bill.totalAmount.toStringAsFixed(0)} đ',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text('Tổng tiền', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBills extends StatelessWidget {
  const _EmptyBills();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 120),
        const Icon(Icons.receipt_long_outlined, size: 72, color: Colors.grey),
        const SizedBox(height: 12),
        Text('Bạn chưa có hóa đơn', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(
          'Khi phát sinh hóa đơn, chúng tôi sẽ hiển thị tại đây.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
        ),
      ],
    );
  }
}
