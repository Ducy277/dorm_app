import 'package:flutter/material.dart';
import '../../../data/models/notification_model.dart';

class NotificationDetailScreen extends StatelessWidget {
  final int? id;
  final NotificationModel? notification;

  const NotificationDetailScreen({super.key, this.id, this.notification});

  @override
  Widget build(BuildContext context) {
    final title = notification?.title ?? 'Thông báo';
    final content =
        notification?.content ?? 'Không tìm thấy nội dung chi tiết.';
    final createdAt = notification?.createdAt ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(notification != null ? 'Thông báo' : 'Thông báo #$id'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (createdAt.isNotEmpty)
              Text(
                createdAt,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.black54),
              ),
            const SizedBox(height: 16),
            Text(content, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
