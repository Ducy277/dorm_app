/// Các hàm kiểm tra dữ liệu đầu vào.
class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải dài ít nhất 6 ký tự';
    }
    return null;
  }

  static String? validateRequired(String? value, {String fieldName = 'Trường'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName không được để trống';
    }
    return null;
  }
}