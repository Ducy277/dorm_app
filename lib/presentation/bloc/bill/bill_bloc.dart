import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/exceptions.dart';
import '../../../data/models/bill_model.dart';
import '../../../data/repositories/bill_repository.dart';
import '../../../data/repositories/payment_repository.dart';

part 'bill_event.dart';
part 'bill_state.dart';

/// Bloc xử lý hóa đơn và thanh toán VNPay.
class BillBloc extends Bloc<BillEvent, BillState> {
  final BillRepository billRepository;
  final PaymentRepository paymentRepository;

  BillBloc({required this.billRepository, required this.paymentRepository})
      : super(BillInitial()) {
    on<FetchBills>(_onFetchBills);
    on<FetchBillDetail>(_onFetchBillDetail);
    on<CreateVnPayPayment>(_onCreateVnPayPayment);
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

  Future<void> _onFetchBillDetail(
    FetchBillDetail event,
    Emitter<BillState> emit,
  ) async {
    emit(BillLoading());
    try {
      final bill = await billRepository.getBillDetail(event.id);
      emit(BillLoaded(bill: bill));
    } on AppException catch (e) {
      emit(BillError(message: e.message));
    }
  }

  Future<void> _onCreateVnPayPayment(
    CreateVnPayPayment event,
    Emitter<BillState> emit,
  ) async {
    BillModel? previousBill;
    if (state is BillLoaded) {
      previousBill = (state as BillLoaded).bill;
    }
    emit(BillLoading());
    try {
      final url = await paymentRepository.createVnPayPaymentUrl(
        billId: event.billId,
        amount: event.amount,
      );
      emit(BillPaymentUrlReady(paymentUrl: url));
      if (previousBill != null) {
        emit(BillLoaded(bill: previousBill));
      }
    } on AppException catch (e) {
      emit(BillError(message: e.message));
      if (previousBill != null) {
        emit(BillLoaded(bill: previousBill));
      }
    }
  }

  Future<void> _onPayBill(PayBillEvent event, Emitter<BillState> emit) async {
    emit(BillLoading());
    try {
      final bill =
          await billRepository.payBill(event.billId, event.amount, event.paymentType);
      emit(BillLoaded(bill: bill));
    } on AppException catch (e) {
      emit(BillError(message: e.message));
    }
  }
}

