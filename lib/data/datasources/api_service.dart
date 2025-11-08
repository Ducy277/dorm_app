import 'dart:io';

import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/error/exceptions.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/secure_storage.dart';

/// Lớp dịch vụ API dựa trên Dio để thực hiện các yêu cầu REST.
class ApiService {
  final Dio _dio;
  final SecureStorage secureStorage;

  ApiService({required this.secureStorage}) : _dio = Dio() {
    _dio.options.baseUrl = ApiEndpoints.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
    _dio.options.responseType = ResponseType.json;
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Chèn header Authorization nếu có token
        final token = await secureStorage.getToken();
        if (token != null) {
          options.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        // Xử lý lỗi 401: token hết hạn hoặc không hợp lệ
        if (error.response?.statusCode == 401) {
          await secureStorage.deleteToken();
          // Có thể thêm logic chuyển hướng đến trang đăng nhập bằng cách phát sự kiện qua Bloc
        }
        return handler.next(error);
      },
    ));
  }

  /// Thực hiện một yêu cầu GET tới [path] với [queryParameters].
  Future<Response<T>> getRequest<T>(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get<T>(path, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Thực hiện một yêu cầu POST tới [path] với [data].
  Future<Response<T>> postRequest<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.post<T>(path, data: data, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Thực hiện một yêu cầu PUT tới [path] với [data].
  Future<Response<T>> putRequest<T>(String path, {dynamic data}) async {
    try {
      final response = await _dio.put<T>(path, data: data);
      return response;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Thực hiện một yêu cầu DELETE tới [path].
  Future<Response<T>> deleteRequest<T>(String path, {dynamic data}) async {
    try {
      final response = await _dio.delete<T>(path, data: data);
      return response;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  Future<Response<T>> postMultipartRequest<T>(
      String path, {
        required FormData data,
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
      return response;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  void _handleDioError(DioException error) {
    Logger.log('API error: ${error.message}');
    if (error.response != null) {
      final statusCode = error.response?.statusCode;
      final message = error.response?.data is Map<String, dynamic>
          ? error.response?.data['message'] ?? 'Đã xảy ra lỗi'
          : error.response?.statusMessage ?? 'Đã xảy ra lỗi';
      if (statusCode == 400 || statusCode == 422) {
        throw ValidationException(message, statusCode: statusCode);
      } else if (statusCode == 401) {
        throw AuthenticationException(message, statusCode: statusCode);
      } else {
        throw NetworkException(message, statusCode: statusCode);
      }
    } else {
      throw NetworkException('Không thể kết nối tới máy chủ');
    }
  }
}