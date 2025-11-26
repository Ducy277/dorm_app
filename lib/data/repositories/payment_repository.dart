import '../../core/constants/api_endpoints.dart';
import '../../core/error/exceptions.dart';
import '../datasources/api_service.dart';

/// Repository xử lý thanh toán VNPay.
class PaymentRepository {
  final ApiService apiService;

  PaymentRepository({required this.apiService});

  Future<String> createVnPayPaymentUrl({
    required int billId,
    required double amount,
  }) async {
    try {
      final response = await apiService.postRequest(
        ApiEndpoints.vnpayRedirect(billId),
        data: {'amount': amount},
      );
      final data = response.data as Map<String, dynamic>;
      final url = data['payment_url'] as String?;
      if (url == null || url.isEmpty) {
        throw AppException('Không nhận được liên kết thanh toán từ VNPay.');
      }
      return url;
    } on ValidationException catch (e) {
      final msg = e.errors?['amount']?.first ?? e.message;
      throw ValidationException(msg, errors: e.errors, statusCode: e.statusCode);
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Không thể tạo yêu cầu thanh toán. Vui lòng thử lại.');
    }
  }
}

