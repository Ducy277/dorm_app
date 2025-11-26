import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// Th��� tA1y ch��%nh dA1ng �`��� hi���n th��< thA'ng tin phA�ng, hA3a �`��n, v.v.
class CustomCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final bool showBorder;

  const CustomCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final borderSide = showBorder
        ? BorderSide(color: AppColors.primary.withOpacity(0.06))
        : BorderSide.none;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: AppSizes.paddingSmall,
          horizontal: AppSizes.paddingMedium,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(width: 1, color: borderSide.color),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppSizes.paddingMedium),
          child: child,
        ),
      ),
    );
  }
}
