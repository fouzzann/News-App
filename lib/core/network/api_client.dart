import 'dart:io';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';

/// Single API client wrapping Dio with typed errors and timeout handling
class ApiClient {
  final Dio _dio;

  ApiClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConstants.baseUrl,
                connectTimeout: ApiConstants.connectTimeout,
                receiveTimeout: ApiConstants.receiveTimeout,
                sendTimeout: ApiConstants.connectTimeout,
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            );

  Dio get dioInstance => _dio;

  /// Perform a GET request with typed error handling
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on SocketException {
      throw const NetworkException();
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(message: e.toString());
    }
  }

  /// Maps [DioException] to domain [AppException]
  AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const RequestTimeoutException();

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode != null && statusCode >= 500) {
          return ServerException(
            message: 'Server error ($statusCode). Please try again later.',
            statusCode: statusCode,
          );
        } else if (statusCode != null && statusCode >= 400) {
          return ClientException(
            message: error.response?.statusMessage ?? 'Request error ($statusCode).',
            statusCode: statusCode,
          );
        }
        return UnknownException(
          message: 'Received invalid status code: $statusCode',
        );

      case DioExceptionType.cancel:
        return const RequestCancelledException();

      case DioExceptionType.badCertificate:
        return const NetworkException(
          message: 'Security certificate verification failed.',
        );

      case DioExceptionType.unknown:
      default:
        if (error.error is SocketException) {
          return const NetworkException();
        }
        return UnknownException(
          message: error.message ?? 'An unexpected network error occurred.',
        );
    }
  }
}
