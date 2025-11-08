import '../../core/constants/api_endpoints.dart';
import '../../core/error/exceptions.dart';
import '../datasources/api_service.dart';
import '../models/bill_model.dart';

/// Repository xử lý dữ liệu hóa đơn.
class BillRepository {
  final ApiService apiService;

  BillRepository({required this.apiService});

  /// Lấy danh sách hóa đơn.
  Future<List<BillModel>> getBills({int? page}) async {
    try {
      final response = await apiService.getRequest(
        ApiEndpoints.bills,
        queryParameters: page != null ? {'page': page} : null,
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['data'] as List? ?? [];
      return list.map((e) => BillModel.fromJson(e)).toList();
    } on AppException {
      rethrow;
    }
  }

  /// Thanh toán hóa đơn.
  Future<BillModel> payBill(int billId, double amount, String paymentType) async {
    try {
      final response = await apiService.postRequest(
        ApiEndpoints.payBill(billId),
        data: {
          'amount': amount,
          'payment_type': paymentType,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return BillModel.fromJson(data['data']);
    } on AppException {
      rethrow;
    }
  }
}