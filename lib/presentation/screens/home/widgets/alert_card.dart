import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../data/models/notification_model.dart';

class QuickNotifications extends StatelessWidget {
  final List<NotificationModel> notifications;
  final void Function(int id)? onTap;

  const QuickNotifications({
    super.key,
    required this.notifications,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thông báo mới',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSizes.paddingSmall),

        // Tăng nhẹ chiều cao cho chắc, khỏi overflow
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = notifications[index];
              final createdLabel = _formatDate(item.createdAt);

              return SizedBox(
                width: 220,
                child: CustomCard(
                  padding: const EdgeInsets.all(AppSizes.paddingSmall),
                  onTap: onTap != null ? () => onTap!(item.id) : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // co đúng theo nội dung
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_active_outlined,
                              color: AppColors.primary,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              createdLabel,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // ❗ Chỉ giữ lại TIÊU ĐỀ
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      // ❌ Không còn SizedBox + Expanded + content nữa
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class QuickNotificationShimmer extends StatelessWidget {
  const QuickNotificationShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        2,
            (index) => Expanded(
          child: Container(
            height: 140, // match với QuickNotifications
            margin: EdgeInsets.only(right: index == 1 ? 0 : 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}

String _formatDate(String raw) {
  try {
    final date = DateTime.parse(raw);
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  } catch (_) {
    return raw;
  }
}
