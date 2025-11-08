import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/custom_card.dart';
import '../../bloc/bill/bill_bloc.dart';

/// Màn hình danh sách hóa đơn.
class BillsScreen extends StatelessWidget {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<BillBloc>().add(const FetchBills());
    return BlocBuilder<BillBloc, BillState>(
      builder: (context, state) {
        if (state is BillLoading) {
          return const LoadingIndicator();
        } else if (state is BillsLoaded) {
          final bills = state.bills;
          if (bills.isEmpty) {
            return const Center(child: Text('Không có hóa đơn nào'));
          }
          return RefreshIndicator(
            onRefresh: () async => context.read<BillBloc>().add(const FetchBills()),
            child: ListView.builder(
              itemCount: bills.length,
              itemBuilder: (context, index) {
                final bill = bills[index];
                return CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hóa đơn #${bill.billCode}', style: Theme.of(context).textTheme.titleMedium),
                      Text('Tổng: ${bill.totalAmount}'),
                      Text('Trạng thái: ${bill.status}'),
                      if (bill.dueDate != null) Text('Hạn: ${bill.dueDate}'),
                    ],
                  ),
                );
              },
            ),
          );
        } else if (state is BillError) {
          return Center(child: Text('Lỗi: ${state.message}'));
        }
        return const SizedBox.shrink();
      },
    );
  }
}