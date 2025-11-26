import '../../core/constants/api_endpoints.dart';
import '../../core/error/exceptions.dart';
import '../../core/utils/secure_storage.dart';
import '../datasources/api_service.dart';
import '../models/user_model.dart';

/// Repository xử lý logic xác thực: đăng nhập, đăng ký, đăng xuất, hồ sơ.
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
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
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

  /// Đăng xuất và xoá token.
  Future<void> logout() async {
    try {
      await apiService.postRequest(ApiEndpoints.logout);
    } catch (_) {
      // bỏ qua lỗi logout
    }
    await secureStorage.deleteToken();
  }

  /// Lấy hồ sơ người dùng hiện tại.
  Future<UserModel> fetchProfile() async {
    try {
      final response = await apiService.getRequest(ApiEndpoints.me);
      final data = response.data as Map<String, dynamic>;
      final payload = data['data'] ?? data;
      return UserModel.fromJson(Map<String, dynamic>.from(payload));
    } on AppException {
      rethrow;
    }
  }

  /// Cập nhật thông tin cá nhân.
  Future<UserModel> updateProfile({
    required String name,
    String? phone,
    String? address,
    String? gender,
    String? dateOfBirth,
    String? studentClass,
  }) async {
    try {
      final payload = <String, dynamic>{
        'name': name,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
        if (gender != null) 'gender': gender,
        if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
        if (studentClass != null) 'class': studentClass,
      };
      final response = await apiService.putRequest(
        ApiEndpoints.profile,
        data: payload,
      );
      final data = response.data as Map<String, dynamic>;
      final payloadData = data['data'] ?? data;
      return UserModel.fromJson(Map<String, dynamic>.from(payloadData));
    } on AppException {
      rethrow;
    }
  }
}

