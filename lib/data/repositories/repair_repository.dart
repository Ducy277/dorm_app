import '../../core/constants/api_endpoints.dart';
import '../../core/error/exceptions.dart';
import '../datasources/api_service.dart';
import '../models/repair_model.dart';

/// Repository xử lý yêu cầu sửa chữa.
class RepairRepository {
  final ApiService apiService;

  RepairRepository({required this.apiService});

  /// Lấy danh sách yêu cầu sửa chữa.
  Future<List<RepairModel>> getRepairs({int? page}) async {
    try {
      final response = await apiService.getRequest(
        ApiEndpoints.repairs,
        queryParameters: page != null ? {'page': page} : null,
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['data'] as List? ?? [];
      return list.map((e) => RepairModel.fromJson(e)).toList();
    } on AppException {
      rethrow;
    }
  }

  /// Gửi yêu cầu sửa chữa mới.
  Future<RepairModel> createRepair({required int roomId, required String description}) async {
    try {
      final response = await apiService.postRequest(
        ApiEndpoints.repairs,
        data: {
          'room_id': roomId,
          'description': description,
          // image_path có thể gửi dưới dạng multipart ở UI
        },
      );
      final data = response.data as Map<String, dynamic>;
      return RepairModel.fromJson(data['data']);
    } on AppException {
      rethrow;
    }
  }
}