import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/exceptions.dart';
import '../../../data/models/bill_model.dart';
import '../../../data/repositories/bill_repository.dart';

part 'bill_event.dart';
part 'bill_state.dart';

/// Bloc xử lý hóa đơn.
class BillBloc extends Bloc<BillEvent, BillState> {
  final BillRepository billRepository;

  BillBloc({required this.billRepository}) : super(BillInitial()) {
    on<FetchBills>(_onFetchBills);
    on<PayBillEvent>(_onPayBill);
  }

  Future<void> _onFetchBills(FetchBills event, Emitter<BillState> emit) async {
    emit(BillLoading());
    try {
      final bills = await billRepository.getBills(page: event.page);
      emit(BillsLoaded(bills: bills));
    } on AppException catch (e) {
      emit(BillError(message: e.message));
    }
  }

  Future<void> _onPayBill(PayBillEvent event, Emitter<BillState> emit) async {
    emit(BillLoading());
    try {
      final bill = await billRepository.payBill(event.billId, event.amount, event.paymentType);
      emit(BillLoaded(bill: bill));
    } on AppException catch (e) {
      emit(BillError(message: e.message));
    }
  }
}