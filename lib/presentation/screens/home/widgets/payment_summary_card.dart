import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';

class PaymentItem {
  final String label;
  final double value;
  final String unit;
  final String? pricePerUnit;
  const PaymentItem({required this.label, required this.value, required this.unit, this.pricePerUnit});
}

class PaymentSummaryCard extends StatelessWidget {
  final List<PaymentItem> items;
  final int daysUntilNextPayment;
  final VoidCallback? onPayTap;
  const PaymentSummaryCard({super.key, required this.items, required this.daysUntilNextPayment, this.onPayTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.paymentBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Danh mục tính tiền', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: items.isEmpty
                      ? [Text('Chưa có dữ liệu', style: GoogleFonts.poppins(fontSize: 14))]
                      : items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: Text(item.label, style: GoogleFonts.poppins(fontSize: 14))),
                                    Text('${item.value.toStringAsFixed(0)}${item.unit}', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                if (item.pricePerUnit != null) ...[
                                  const SizedBox(height: 2),
                                  Text(item.pricePerUnit!, style: GoogleFonts.poppins(fontSize: 12, color: Colors.redAccent)),
                                ],
                              ],
                            ),
                          );
                        }).toList(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(daysUntilNextPayment.toString(), style: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                    Text('ngày trước kỳ\nthanh toán\nkế tiếp', style: GoogleFonts.poppins(fontSize: 14), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.paymentButton,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onPayTap,
              child: Text('Thanh toán', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
