import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Lớp bao bọc [FlutterSecureStorage] dùng để lưu trữ token an toàn.
class SecureStorage {
  static const _tokenKey = 'auth_token';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Lưu token vào bộ nhớ an toàn.
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Lấy token hiện tại.
  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  /// Xóa token khỏi bộ nhớ an toàn.
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
}