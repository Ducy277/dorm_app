import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';

/// Thẻ tùy chỉnh dùng để hiển thị thông tin phòng, hóa đơn, v.v.
class CustomCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const CustomCard({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(
          vertical: AppSizes.paddingSmall,
          horizontal: AppSizes.paddingMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: child,
        ),
      ),
    );
  }
}