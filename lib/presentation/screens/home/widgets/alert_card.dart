import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';

enum AlertPriority { high, medium, low }

class AlertCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onTap;
  final AlertPriority priority;

  const AlertCard({super.key, required this.title, required this.description, this.onTap, this.priority = AlertPriority.medium});

  Color get _backgroundColor {
    switch (priority) {
      case AlertPriority.high:
        return AppColors.alertHighBackground;
      case AlertPriority.medium:
        return AppColors.alertMediumBackground;
      case AlertPriority.low:
      default:
        return AppColors.alertLowBackground;
    }
  }

  Color get _accentColor {
    switch (priority) {
      case AlertPriority.high:
        return AppColors.alertHighAccent;
      case AlertPriority.medium:
        return AppColors.alertMediumAccent;
      case AlertPriority.low:
      default:
        return AppColors.alertLowAccent;
    }
  }

  IconData get _icon {
    switch (priority) {
      case AlertPriority.high:
        return Icons.warning_amber_rounded;
      case AlertPriority.medium:
        return Icons.notifications_active_outlined;
      case AlertPriority.low:
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: _accentColor.withAlpha(38), shape: BoxShape.circle),
              child: Icon(_icon, color: _accentColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: _accentColor)),
                  const SizedBox(height: 4),
                  Text(description, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87)),
                ],
              ),
            ),
            Text('Xem thêm', style: GoogleFonts.poppins(fontSize: 12, color: _accentColor, decoration: TextDecoration.underline)),
          ],
        ),
      ),
    );
  }
}
