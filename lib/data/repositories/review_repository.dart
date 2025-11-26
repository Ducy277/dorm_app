import '../../core/constants/api_endpoints.dart';
import '../../core/error/exceptions.dart';
import '../datasources/api_service.dart';
import '../models/review_model.dart';

/// Repository xử lý đánh giá phòng.
class ReviewRepository {
  final ApiService apiService;

  ReviewRepository({required this.apiService});

  Future<List<ReviewModel>> getRoomReviews(int roomId) async {
    try {
      final response = await apiService.getRequest(ApiEndpoints.room(roomId));
      final data = response.data as Map<String, dynamic>;
      final body = data['data'] ?? data;
      final list = body['reviews'] as List? ?? [];
      return list
          .whereType<Map<String, dynamic>>()
          .map((e) => ReviewModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on AppException {
      rethrow;
    }
  }

  Future<void> submitReview({
    required int roomId,
    required int rating,
    required String comment,
  }) async {
    try {
      await apiService.postRequest(
        '/rooms/$roomId/reviews',
        data: { 'rating': rating, 'comment': comment },
      );
    } on ValidationException catch (e) {
      final msg = e.errors?['rating']?.first ??
          e.errors?['comment']?.first ??
          e.message;
      throw ValidationException(msg, errors: e.errors, statusCode: e.statusCode);
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Không thể gửi đánh giá. Vui lòng thử lại.');
    }
  }
}
