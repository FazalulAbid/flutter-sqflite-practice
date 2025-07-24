import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite_practice_project/core/data/network/dio_client.dart';
import 'package:sqflite_practice_project/core/domain/utils/app_failure.dart';
import 'package:sqflite_practice_project/core/domain/utils/result.dart';

part 'network_client.g.dart';

@riverpod
NetworkClient networkClient(Ref ref) {
  final dio = ref.watch(dioClientProvider);
  return NetworkClient(dio);
}

class NetworkClient {
  final Dio _dio;

  NetworkClient(this._dio);

  Future<Result<T>> getRequest<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return Result.success(fromJson(response.data));
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  Future<Result<List<T>>> getListRequest<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      final List<dynamic> data = response.data as List<dynamic>;
      final List<T> result = data.map((item) => fromJson(item as Map<String, dynamic>)).toList();

      return Result.success(result);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  Future<Result<T>> postRequest<T>(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return Result.success(fromJson(response.data));
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  Future<Result<T>> putRequest<T>(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return Result.success(fromJson(response.data));
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  Future<Result<T>> patchRequest<T>(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return Result.success(fromJson(response.data));
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  Future<Result<void>> deleteRequest(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return const Result.success(null);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  AppFailure _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const AppFailure.network(
            message: 'Connection timeout. Please check your internet connection.',
          );

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = _getErrorMessageFromResponse(error.response);

          if (statusCode == 401) {
            return AppFailure.authentication(message: message);
          } else if (statusCode != null && statusCode >= 400 && statusCode < 500) {
            return AppFailure.validation(message: message);
          } else if (statusCode != null && statusCode >= 500) {
            return AppFailure.server(message: message, statusCode: statusCode);
          }

          return AppFailure.network(message: message, statusCode: statusCode);

        case DioExceptionType.cancel:
          return const AppFailure.network(message: 'Request was cancelled');

        case DioExceptionType.connectionError:
          return const AppFailure.network(
            message: 'No internet connection. Please check your network settings.',
          );

        case DioExceptionType.badCertificate:
          return const AppFailure.network(message: 'Certificate verification failed');

        case DioExceptionType.unknown:
        default:
          return AppFailure.unknown(message: error.message ?? 'An unexpected error occurred');
      }
    }

    return AppFailure.unknown(
      message: error.toString().isNotEmpty ? error.toString() : 'An unexpected error occurred',
    );
  }

  String _getErrorMessageFromResponse(Response? response) {
    if (response?.data != null) {
      try {
        final data = response!.data;
        if (data is Map<String, dynamic>) {
          // Try common error message fields
          if (data.containsKey('message')) {
            return data['message'].toString();
          } else if (data.containsKey('error')) {
            return data['error'].toString();
          } else if (data.containsKey('detail')) {
            return data['detail'].toString();
          }
        }
      } catch (e) {
      }
    }

    return 'An error occurred. Please try again.';
  }
}
