import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:oms/api_config/dio_client.dart';
import 'package:oms/app_config/app_constants.dart';
import 'package:oms/services/toast_service.dart';

/// Centralized API Repository managing REST requests, request cancellation,
/// base URL concatenation, and unified error handling with customizable toast feedback.
class ApiRepo {
  ApiRepo._internal();

  /// Singleton instance of [ApiRepo].
  static final ApiRepo instance = ApiRepo._internal();

  static final DioClient _dioClient = DioClient.instance;

  /// Cancels all active and in-flight API requests.
  static void cancelAllRequests({String reason = 'Cancelled all API calls'}) {
    _dioClient.cancelAllRequests(reason: reason);
  }

  /// Resolves API URL by concatenating base URL from [app_constants.dart] with relative API path: "${AppConstants.getBaseUrl()}$apiPath"
  static String _apiBaseUrl(String apiPath) {
    if (apiPath.startsWith('http://') || apiPath.startsWith('https://')) {
      return apiPath;
    }
    final path = apiPath.startsWith('/') ? apiPath : '/$apiPath';
    return "${AppConstants.getBaseUrl()}$path";
  }

  // ===========================================================================
  // CENTRALIZED UNIFIED ERROR HANDLER
  // ===========================================================================

  /// Reusable standalone function to parse API errors across pages & repositories.
  ///
  /// Parses [DioException] and raw exceptions, extracts human-readable error text
  /// or server JSON payload. Conditionally displays a toast if [showToast] is `true`.
  /// Always returns the parsed error response/message so callers can handle it manually.
  static dynamic handleApiError({
    required dynamic error,
    bool showToast = true,
  }) {
    String errorMessage = 'An unexpected error occurred. Please try again.';
    dynamic errorData;

    if (error is DioException) {
      // Avoid showing toasts for intentionally cancelled requests
      if (error.type == DioExceptionType.cancel) {
        log('Request cancelled: ${error.message}');
        return 'Request cancelled.';
      }

      final response = error.response;
      if (response != null && response.data != null) {
        errorData = response.data;
        errorMessage = _extractErrorMessage(response.data) ?? errorMessage;
      } else {
        switch (error.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
          case DioExceptionType.transformTimeout:
            errorMessage = 'Connection timeout. Please check your network.';
            break;
          case DioExceptionType.connectionError:
            errorMessage =
                'Unable to connect to server. Check your internet connection.';
            break;
          case DioExceptionType.badCertificate:
            errorMessage = 'Secure connection error (Bad Certificate).';
            break;
          case DioExceptionType.unknown:
            errorMessage = error.message ?? errorMessage;
            break;
          default:
            errorMessage = 'Network error occurred.';
            break;
        }
      }
    } else if (error is Exception) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } else if (error is String) {
      errorMessage = error;
    }

    log('API Error: $errorMessage');

    // Show error toast ONLY if showToast is true and request was not cancelled
    if (showToast &&
        (error is! DioException || error.type != DioExceptionType.cancel)) {
      ToastService.showErrorToast(errorMessage);
    }

    return errorData ?? errorMessage;
  }

  /// Extracts readable error text from server JSON response payload (Map or String).
  static String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      if (data['message'] != null) {
        if (data['message'] is String) return data['message'] as String;
        if (data['message'] is Map) {
          final mapMsg = data['message'] as Map;
          if (mapMsg.isNotEmpty) {
            final firstVal = mapMsg.values.first;
            if (firstVal is List && firstVal.isNotEmpty) {
              return firstVal.first.toString();
            }
            return firstVal.toString();
          }
        }
      }
      if (data['errors'] != null) {
        if (data['errors'] is String) return data['errors'] as String;
        if (data['errors'] is Map) {
          final errMap = data['errors'] as Map;
          if (errMap.isNotEmpty) {
            final firstVal = errMap.values.first;
            if (firstVal is List && firstVal.isNotEmpty) {
              return firstVal.first.toString();
            }
            return firstVal.toString();
          }
        }
      }
      if (data['error'] != null) {
        return data['error'].toString();
      }
    } else if (data is String && data.isNotEmpty) {
      return data;
    }

    return null;
  }

  // ===========================================================================
  // REST API METHODS
  // ===========================================================================

  /// Executes an HTTP GET request. Concatenates "${getBaseUrl()}$apiPath".
  ///
  /// Set [cancelPrevious] to `true` to cancel all previous in-flight API calls.
  /// Set [showToast] to `false` to suppress automatic error toasts and handle error responses manually.
  static Future<dynamic> apiGet({
    required String apiPath,
    dynamic queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool cancelPrevious = false,
    bool showToast = true,
  }) async {
    if (cancelPrevious) {
      cancelAllRequests(
          reason: 'Cancelled by new GET request (cancelPrevious=true)');
    }

    final token = _dioClient.registerCancelToken(cancelToken);
    final url = _apiBaseUrl(apiPath);

    try {
      final response = await dio.get(
        url,
        queryParameters:
            queryParameters is Map<String, dynamic> ? queryParameters : null,
        options: options,
        cancelToken: token,
      );

      return response.data;
    } catch (e) {
      return handleApiError(error: e, showToast: showToast);
    } finally {
      _dioClient.unregisterCancelToken(token);
    }
  }

  /// Executes an HTTP POST request. Concatenates "${getBaseUrl()}$apiPath".
  ///
  /// Set [cancelPrevious] to `true` to cancel all previous in-flight API calls.
  /// Set [showToast] to `false` to suppress automatic error toasts and handle error responses manually.
  static Future<dynamic> apiPost({
    required String apiPath,
    dynamic data,
    dynamic queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool cancelPrevious = false,
    bool showToast = true,
  }) async {
    if (cancelPrevious) {
      cancelAllRequests(
          reason: 'Cancelled by new POST request (cancelPrevious=true)');
    }

    final token = _dioClient.registerCancelToken(cancelToken);
    final url = _apiBaseUrl(apiPath);

    try {
      final response = await dio.post(
        url,
        data: data,
        queryParameters:
            queryParameters is Map<String, dynamic> ? queryParameters : null,
        options: options,
        cancelToken: token,
      );

      return response.data;
    } catch (e) {
      return handleApiError(error: e, showToast: showToast);
    } finally {
      _dioClient.unregisterCancelToken(token);
    }
  }

  /// Executes an HTTP PUT request. Concatenates "${getBaseUrl()}$apiPath".
  ///
  /// Set [cancelPrevious] to `true` to cancel all previous in-flight API calls.
  /// Set [showToast] to `false` to suppress automatic error toasts and handle error responses manually.
  static Future<dynamic> apiPut({
    required String apiPath,
    dynamic data,
    dynamic queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool cancelPrevious = false,
    bool showToast = true,
  }) async {
    if (cancelPrevious) {
      cancelAllRequests(
          reason: 'Cancelled by new PUT request (cancelPrevious=true)');
    }

    final token = _dioClient.registerCancelToken(cancelToken);
    final url = _apiBaseUrl(apiPath);

    try {
      final response = await dio.put(
        url,
        data: data,
        queryParameters:
            queryParameters is Map<String, dynamic> ? queryParameters : null,
        options: options,
        cancelToken: token,
      );

      return response.data;
    } catch (e) {
      return handleApiError(error: e, showToast: showToast);
    } finally {
      _dioClient.unregisterCancelToken(token);
    }
  }

  /// Executes an HTTP PATCH request. Concatenates "${getBaseUrl()}$apiPath".
  ///
  /// Set [cancelPrevious] to `true` to cancel all previous in-flight API calls.
  /// Set [showToast] to `false` to suppress automatic error toasts and handle error responses manually.
  static Future<dynamic> apiPatch({
    required String apiPath,
    dynamic data,
    dynamic queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool cancelPrevious = false,
    bool showToast = true,
  }) async {
    if (cancelPrevious) {
      cancelAllRequests(
          reason: 'Cancelled by new PATCH request (cancelPrevious=true)');
    }

    final token = _dioClient.registerCancelToken(cancelToken);
    final url = _apiBaseUrl(apiPath);

    try {
      final response = await dio.patch(
        url,
        data: data,
        queryParameters:
            queryParameters is Map<String, dynamic> ? queryParameters : null,
        options: options,
        cancelToken: token,
      );

      return response.data;
    } catch (e) {
      return handleApiError(error: e, showToast: showToast);
    } finally {
      _dioClient.unregisterCancelToken(token);
    }
  }

  /// Executes an HTTP DELETE request. Concatenates "${getBaseUrl()}$apiPath".
  ///
  /// Set [cancelPrevious] to `true` to cancel all previous in-flight API calls.
  /// Set [showToast] to `false` to suppress automatic error toasts and handle error responses manually.
  static Future<dynamic> apiDelete({
    required String apiPath,
    dynamic data,
    dynamic queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool cancelPrevious = false,
    bool showToast = true,
  }) async {
    if (cancelPrevious) {
      cancelAllRequests(
          reason: 'Cancelled by new DELETE request (cancelPrevious=true)');
    }

    final token = _dioClient.registerCancelToken(cancelToken);
    final url = _apiBaseUrl(apiPath);

    try {
      final response = await dio.delete(
        url,
        data: data,
        queryParameters:
            queryParameters is Map<String, dynamic> ? queryParameters : null,
        options: options,
        cancelToken: token,
      );

      return response.data;
    } catch (e) {
      return handleApiError(error: e, showToast: showToast);
    } finally {
      _dioClient.unregisterCancelToken(token);
    }
  }
}
