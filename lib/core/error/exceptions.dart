/// Định nghĩa các ngoại lệ phát sinh từ tầng dữ liệu.
library;

class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, {this.statusCode});

  @override
  String toString() => 'AppException(statusCode: $statusCode, message: $message)';
}

class NetworkException extends AppException {
  NetworkException(super.message, {super.statusCode});
}

class AuthenticationException extends AppException {
  AuthenticationException(super.message, {super.statusCode});
}

class ValidationException extends AppException {
  final Map<String, List<String>>? errors;
  ValidationException(super.message, {this.errors, super.statusCode});
}

class ServerException extends AppException {
  ServerException(super.message, {super.statusCode});}

class NotFoundException extends AppException {
  NotFoundException(super.message, {super.statusCode});
}

class UnknownException extends AppException {
  UnknownException(super.message, {super.statusCode});
}