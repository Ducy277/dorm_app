

import '../../core/constants/api_endpoints.dart';
import '../../core/error/exceptions.dart';
import '../../core/utils/secure_storage.dart';
import '../datasources/api_service.dart';
import '../models/user_model.dart';

/// Repository xử lý logic xác thực: đăng nhập, đăng ký, đăng xuất.
class AuthRepository {
  final ApiService apiService;
  final SecureStorage secureStorage;

  AuthRepository({required this.apiService, required this.secureStorage});

  /// Đăng nhập và lưu token nếu thành công.
  Future<UserModel> login({required String email, required String password}) async {
    try {
      final response = await apiService.postRequest(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      final data = response.data as Map<String, dynamic>;
      // Giả định API trả về { success: true, data: { user: {...}, token: '...' } }
      final token = data['token'] as String?;
      if (token != null) {
        await secureStorage.saveToken(token);
      }
      final userJson = data['user'] as Map<String, dynamic>;
      return UserModel.fromJson(userJson);
    } on AppException {
      rethrow;
    }
  }

  /// Đăng ký tài khoản mới.
  Future<UserModel> register({required String name, required String email, required String password}) async {
    try {
      final response = await apiService.postRequest(
        ApiEndpoints.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String?;
      if (token != null) {
        await secureStorage.saveToken(token);
      }
      final userJson = data['user'] as Map<String, dynamic>;
      return UserModel.fromJson(userJson);
    } on AppException {
      rethrow;
    }
  }

  /// Đăng xuất và xóa token.
  Future<void> logout() async {
    try {
      await apiService.postRequest(ApiEndpoints.logout);
    } catch (_) {
      // Bỏ qua lỗi logout
    }
    await secureStorage.deleteToken();
  }
}