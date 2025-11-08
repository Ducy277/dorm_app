import 'package:equatable/equatable.dart';

import 'booking_entity.dart';

/// Thực thể hoá đơn.
class BillEntity extends Equatable {
  final int id;
  final String billCode;
  final int userId;
  final int bookingId;
  final double totalAmount;
  final String status;
  final String? dueDate;
  final List<BillItemEntity> billItems;
  final List<PaymentEntity> payments;
  final BookingEntity? booking;

  const BillEntity({
    required this.id,
    required this.billCode,
    required this.userId,
    required this.bookingId,
    required this.totalAmount,
    required this.status,
    this.dueDate,
    this.billItems = const [],
    this.payments = const [],
    this.booking,
  });

  @override
  List<Object?> get props => [
        id,
        billCode,
        userId,
        bookingId,
        totalAmount,
        status,
        dueDate,
        billItems,
        payments,
        booking,
      ];
}

/// Hạng mục hoá đơn (dòng chi tiết).
class BillItemEntity extends Equatable {
  final int id;
  final int billId;
  final String description;
  final double amount;

  const BillItemEntity({required this.id, required this.billId, required this.description, required this.amount});

  @override
  List<Object?> get props => [id, billId, description, amount];
}

/// Thực thể thanh toán.
class PaymentEntity extends Equatable {
  final int id;
  final int billId;
  final String paymentType;
  final double amount;
  final String? paidAt;

  const PaymentEntity({required this.id, required this.billId, required this.paymentType, required this.amount, this.paidAt});

  @override
  List<Object?> get props => [id, billId, paymentType, amount, paidAt];
}