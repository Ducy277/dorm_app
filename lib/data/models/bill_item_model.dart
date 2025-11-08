import '../../domain/entities/bill_entity.dart';

/// Hạng mục trên hóa đơn.
class BillItemModel {
  final int id;
  final int billId;
  final String description;
  final double amount;

  BillItemModel({required this.id, required this.billId, required this.description, required this.amount});

  factory BillItemModel.fromJson(Map<String, dynamic> json) {
    return BillItemModel(
      id: json['id'] as int,
      billId: json['bill_id'] as int,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  BillItemEntity toEntity() {
    return BillItemEntity(
      id: id,
      billId: billId,
      description: description,
      amount: amount,
    );
  }
}