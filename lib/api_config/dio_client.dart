import 'package:dio/dio.dart';
import 'package:oms/api_config/dio_interceptor.dart';
import 'package:oms/app_config/app_constants.dart';

/// Singleton manager for [Dio] HTTP client and request cancellation tokens.
class DioClient {
  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.getBaseUrl(),
        headers: <String, String>{
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        receiveDataWhenStatusError: true,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    );

    // Attach DioInterceptor
    _dio.interceptors.add(DioInterceptor(dio: _dio));
  }

  /// Singleton instance of [DioClient].
  static final DioClient instance = DioClient._internal();

  late final Dio _dio;
  final Set<CancelToken> _cancelTokens = {};

  /// Access underlying [Dio] instance.
  Dio get dio => _dio;

  /// Creates and registers a [CancelToken] for an API request.
  CancelToken registerCancelToken([CancelToken? token]) {
    final cancelToken = token ?? CancelToken();
    _cancelTokens.add(cancelToken);
    return cancelToken;
  }

  /// Removes a completed or cancelled [CancelToken] from tracking.
  void unregisterCancelToken(CancelToken? token) {
    if (token != null) {
      _cancelTokens.remove(token);
    }
  }

  /// Cancels ALL active and in-flight API requests immediately.
  void cancelAllRequests(
      {String reason = 'Operation cancelled by new request'}) {
    for (final token in _cancelTokens) {
      if (!token.isCancelled) {
        token.cancel(reason);
      }
    }
    _cancelTokens.clear();
  }
}

/// Global top-level instance of [Dio] for direct access.
final dio = DioClient.instance.dio;
