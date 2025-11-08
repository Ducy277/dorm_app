import '../../domain/entities/bill_entity.dart';
import 'booking_model.dart';
import 'bill_item_model.dart';
import 'payment_model.dart';

/// Model đại diện cho hóa đơn.
class BillModel {
  final int id;
  final String billCode;
  final int userId;
  final int bookingId;
  final double totalAmount;
  final String status;
  final String? dueDate;
  final List<BillItemModel>? billItems;
  final List<PaymentModel>? payments;
  final BookingModel? booking;

  BillModel({
    required this.id,
    required this.billCode,
    required this.userId,
    required this.bookingId,
    required this.totalAmount,
    required this.status,
    this.dueDate,
    this.billItems,
    this.payments,
    this.booking,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['id'] as int,
      billCode: json['bill_code'] as String,
      userId: json['user_id'] as int,
      bookingId: json['booking_id'] as int,
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: json['status'] as String,
      dueDate: json['due_date'] as String?,
      billItems: (json['bill_items'] as List?)?.map((e) => BillItemModel.fromJson(e)).toList(),
      payments: (json['payments'] as List?)?.map((e) => PaymentModel.fromJson(e)).toList(),
      booking: json['booking'] != null ? BookingModel.fromJson(json['booking']) : null,
    );
  }

  BillEntity toEntity() {
    return BillEntity(
      id: id,
      billCode: billCode,
      userId: userId,
      bookingId: bookingId,
      totalAmount: totalAmount,
      status: status,
      dueDate: dueDate,
      billItems: billItems?.map((e) => e.toEntity()).toList() ?? [],
      payments: payments?.map((e) => e.toEntity()).toList() ?? [],
      booking: booking?.toEntity(),
    );
  }
}