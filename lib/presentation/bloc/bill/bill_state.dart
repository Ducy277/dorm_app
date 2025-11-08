part of 'bill_bloc.dart';

/// Các trạng thái của BillBloc.
abstract class BillState extends Equatable {
  const BillState();
  @override
  List<Object?> get props => [];
}

class BillInitial extends BillState {}

class BillLoading extends BillState {}

class BillsLoaded extends BillState {
  final List<BillModel> bills;
  const BillsLoaded({required this.bills});
  @override
  List<Object?> get props => [bills];
}

class BillLoaded extends BillState {
  final BillModel bill;
  const BillLoaded({required this.bill});
  @override
  List<Object?> get props => [bill];
}

class BillError extends BillState {
  final String message;
  const BillError({required this.message});
  @override
  List<Object?> get props => [message];
}