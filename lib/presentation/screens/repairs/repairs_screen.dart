import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../bloc/repair/repair_bloc.dart';

/// Màn hình dánh sách yêu cầu sửa chữa
class RepairsScreen extends StatefulWidget {
  const RepairsScreen({super.key});

  @override
  State<RepairsScreen> createState() => _RepairsScreenState();
}

class _RepairsScreenState extends State<RepairsScreen> {
  bool _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded) {
      context.read<RepairBloc>().add(const FetchRepairs());
      _hasLoaded = true;
    }
  }

  Future<void> _refresh() async {
    context.read<RepairBloc>().add(const FetchRepairs());
  }

  Future<void> _openRequestForm() async {
    final created = await context.push<bool>('/repairs/request');
    if (created == true && mounted) {
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yêu cầu sửa chữa')),
      body: BlocBuilder<RepairBloc, RepairState>(
        builder: (context, state) {
          if (state is RepairLoading) {
            return const LoadingIndicator();
          } else if (state is RepairError) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: [
                  const SizedBox(height: 160),
                  Center(child: Text('Lỗi: ${state.message}')),
                ],
              ),
            );
          } else if (state is RepairsLoaded) {
            if (state.repairs.isEmpty) {
              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  children: const [
                    SizedBox(height: 160),
                    Center(child: Text('Bạn chưa gửi yêu cầu nào.')),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: state.repairs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final repair = state.repairs[index];
                  return _RepairCard(repair: repair);
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openRequestForm,
        icon: const Icon(Icons.add),
        label: const Text('Gửi yêu cầu'),
      ),
    );
  }
}

class _RepairCard extends StatelessWidget {
  final dynamic repair;
  const _RepairCard({required this.repair});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF2E7D32);
      case 'processing':
        return const Color(0xFFFFA000);
      default:
        return AppColors.primary;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Hoàn thành';
      case 'processing':
        return 'Đang xử lý';
      default:
        return 'Đã gửi';
    }
  }

  @override
  Widget build(BuildContext context) {
    final room = repair.room;
    final branch = room?.branchName ?? '';
    final title = (repair.description as String?)?.split('\n').first ?? 'Yêu cầu #${repair.id}';
    return CustomCard(
      onTap: () => _showDetail(context, repair),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusColor(repair.status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _statusLabel(repair.status),
                  style: TextStyle(
                    color: _statusColor(repair.status),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (room != null)
            Text(
              'Phòng ${room.roomCode}${branch.isNotEmpty ? ' • $branch' : ''}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
            ),
          const SizedBox(height: 8),
          Text(
            repair.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => _showDetail(context, repair),
                icon: const Icon(Icons.chevron_right),
                label: const Text('Chi tiết'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, dynamic repair) {
    final room = repair.room;
    final branch = room?.branchName ?? '';
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Chi tiết yêu cầu', style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _statusColor(repair.status).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _statusLabel(repair.status),
                      style: TextStyle(color: _statusColor(repair.status), fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (room != null) Text('Phòng: ${room.roomCode}${branch.isNotEmpty ? ' • $branch' : ''}'),
              if (repair.completedAt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('Hoàn thành: ${repair.completedAt}'),
                ),
              const SizedBox(height: 10),
              Text('Mô tả vấn đề', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(repair.description),
            ],
          ),
        );
      },
    );
  }
}
