import '../../domain/entities/bill_entity.dart';

/// Thông tin thanh toán hóa đơn.
class PaymentModel {
  final int id;
  final int billId;
  final String paymentType;
  final double amount;
  final String? paidAt;

  PaymentModel({
    required this.id,
    required this.billId,
    required this.paymentType,
    required this.amount,
    this.paidAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as int,
      billId: json['bill_id'] as int,
      paymentType: json['payment_type'] as String,
      amount: (json['amount'] as num).toDouble(),
      paidAt: json['paid_at'] as String?,
    );
  }

  PaymentEntity toEntity() {
    return PaymentEntity(
      id: id,
      billId: billId,
      paymentType: paymentType,
      amount: amount,
      paidAt: paidAt,
    );
  }
}