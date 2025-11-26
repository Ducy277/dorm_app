part of 'bill_bloc.dart';

/// Các sự kiện của BillBloc.
abstract class BillEvent extends Equatable {
  const BillEvent();
  @override
  List<Object?> get props => [];
}

class FetchBills extends BillEvent {
  final int? page;
  const FetchBills({this.page});
  @override
  List<Object?> get props => [page];
}

class FetchBillDetail extends BillEvent {
  final int id;
  const FetchBillDetail({required this.id});
  @override
  List<Object?> get props => [id];
}

class CreateVnPayPayment extends BillEvent {
  final int billId;
  final double amount;
  const CreateVnPayPayment({required this.billId, required this.amount});
  @override
  List<Object?> get props => [billId, amount];
}

class PayBillEvent extends BillEvent {
  final int billId;
  final double amount;
  final String paymentType;
  const PayBillEvent({required this.billId, required this.amount, required this.paymentType});
  @override
  List<Object?> get props => [billId, amount, paymentType];
}
