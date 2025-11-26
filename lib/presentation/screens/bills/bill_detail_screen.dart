import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../data/models/bill_item_model.dart';
import '../../../data/models/payment_model.dart';
import '../../bloc/bill/bill_bloc.dart';

class BillDetailScreen extends StatefulWidget {
  final int billId;
  const BillDetailScreen({super.key, required this.billId});

  @override
  State<BillDetailScreen> createState() => _BillDetailScreenState();
}

class _BillDetailScreenState extends State<BillDetailScreen> {
  bool _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded) {
      context.read<BillBloc>().add(FetchBillDetail(id: widget.billId));
      _hasLoaded = true;
    }
  }

  Future<void> _refresh() async {
    context.read<BillBloc>().add(FetchBillDetail(id: widget.billId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết hóa đơn')),
      body: BlocConsumer<BillBloc, BillState>(
        listener: (context, state) async {
          if (state is BillPaymentUrlReady) {
            final uri = Uri.parse(state.paymentUrl);
            if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Không mở được trang thanh toán.')),
              );
            }
          } else if (state is BillError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
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
          if (state is! BillLoaded) return const SizedBox.shrink();
          return RefreshIndicator(
            onRefresh: _refresh,
            child: _BillDetailContent(bill: state.bill),
          );
        },
      ),
    );
  }
}

class _BillDetailContent extends StatelessWidget {
  final dynamic bill;
  const _BillDetailContent({required this.bill});

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

  @override
  Widget build(BuildContext context) {
    final List<BillItemModel> items =
        bill.billItems?.cast<BillItemModel>() ?? const <BillItemModel>[];
    final List<PaymentModel> payments =
        bill.payments?.cast<PaymentModel>() ?? const <PaymentModel>[];
    final paidAmount =
    payments.fold<double>(0, (double sum, PaymentModel p) => sum + p.amount);
    final remaining = (bill.totalAmount - paidAmount).clamp(0, bill.totalAmount);
    final canPay = bill.status.toLowerCase() == 'unpaid' ||
        bill.status.toLowerCase() == 'partial';

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          children: [
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hóa đơn #${bill.billCode}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (bill.dueDate != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Hạn thanh toán: ${bill.dueDate}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _statusColor(bill.status).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _statusLabel(bill.status),
                          style: TextStyle(
                            color: _statusColor(bill.status),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Tổng tiền', style: Theme.of(context).textTheme.bodySmall),
                  Text(
                    '${bill.totalAmount.toStringAsFixed(0)} đ',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text('Đã thanh toán: ${paidAmount.toStringAsFixed(0)} đ'),
                  Text('Còn lại: ${remaining.toStringAsFixed(0)} đ'),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            _Section(
              title: 'Chi tiết dịch vụ',
              child: items.isEmpty
                  ? Text('Không có hạng mục.', style: Theme.of(context).textTheme.bodyMedium)
                  : Column(
                children: items
                    .map(
                      (item) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.description),
                    trailing: Text('${item.amount.toStringAsFixed(0)} đ'),
                  ),
                )
                    .toList(),
              ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            _Section(
              title: 'Thông tin thanh toán',
              child: payments.isEmpty
                  ? Text('Chưa thanh toán.', style: Theme.of(context).textTheme.bodyMedium)
                  : Column(
                children: payments
                    .map(
                      (payment) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.payments_outlined),
                    title: Text('${payment.amount.toStringAsFixed(0)} đ'),
                    subtitle: Text('Phương thức: ${payment.paymentType}'),
                    trailing: Text(payment.paidAt ?? ''),
                  ),
                )
                    .toList(),
              ),
            ),
            const SizedBox(height: 90),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                if (canPay)
                  Expanded(
                    child: CustomButton(
                      label: 'Thanh toán ngay',
                      onPressed: () => _showPaymentSheet(context, bill, remaining.toDouble()),
                      icon: Icons.payment,
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _statusColor(bill.status).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _statusLabel(bill.status),
                      style: TextStyle(color: _statusColor(bill.status), fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showPaymentSheet(BuildContext context, dynamic bill, double remaining) {
    final amountCtrl = TextEditingController(text: remaining.toStringAsFixed(0));
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Thanh toán VNPay', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('Tổng tiền: ${bill.totalAmount.toStringAsFixed(0)} đ'),
              Text('Đã thanh toán: ${(bill.totalAmount - remaining).toStringAsFixed(0)} đ'),
              Text('Còn lại: ${remaining.toStringAsFixed(0)} đ'),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Số tiền muốn thanh toán',
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: 'Tạo yêu cầu thanh toán',
                  onPressed: () {
                    final raw = amountCtrl.text.trim();
                    final amount = double.tryParse(raw);
                    if (amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Số tiền không hợp lệ')),
                      );
                      return;
                    }
                    Navigator.pop(context);
                    context.read<BillBloc>().add(
                      CreateVnPayPayment(
                        billId: bill.id,
                        amount: amount,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
