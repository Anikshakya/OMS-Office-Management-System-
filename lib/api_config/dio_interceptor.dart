import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:oms/services/cache_service.dart';

/// Dio Interceptor handling authentication headers, request/response logging,
/// and HTTP error status checks.
class DioInterceptor extends Interceptor {
  final Dio? dio;

  DioInterceptor({this.dio});

  // In-memory access token.
  static String? _accessToken;

  /// Updates the cached access token.
  ///
  /// This token will be used for subsequent API requests.
  static void setAccessToken(String? accessToken) {
    _accessToken = accessToken;
  }

  /// Clears the cached access token.
  static void clearAccessToken() {
    _accessToken = null;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Prefer the in-memory token set through setAccessToken().
    // Fall back to the persisted token from storage.
    final token = _accessToken ?? read(StorageKeys.apiToken);

    if (token != null && token.toString().isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    } else {
      // Make sure an old Authorization header is not accidentally reused.
      options.headers.remove('Authorization');
    }

    log('\x1B[34mREQUEST => [${options.method}] ${options.path}\x1B[0m');

    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final apiPath = response.requestOptions.path;

    final successLog =
        'SUCCESS PATH => [${response.requestOptions.method}] '
        '$apiPath (${response.statusCode})';

    log('\x1B[32m$successLog\x1B[0m');

    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final method = err.requestOptions.method;
    final path = err.requestOptions.path;
    final statusCode = err.response?.statusCode;

    final errorMsg =
        'ERROR PATH => [$method] $path '
        '(Status: ${statusCode ?? 'Unknown'})';

    log('\x1B[31m$errorMsg\x1B[0m');

    // Handle 401 Unauthorized / 403 Forbidden.
    if (statusCode == 401 || statusCode == 403) {
      log('\x1B[33mAUTH EXPIRED => [$statusCode] $path\x1B[0m');
    }

    return super.onError(err, handler);
  }
}
