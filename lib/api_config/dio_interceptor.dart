import 'dart:developer';
import 'package:dio/dio.dart';

/// Dio Interceptor handling authentication headers, request/response logging,
/// and HTTP error status checks.
class DioInterceptor extends Interceptor {
  final Dio? dio;

  DioInterceptor({this.dio});

  // Token cache (Can be set via Auth manager)
  static String? _accessToken;

  /// Updates cached access token.
  static void setAccessToken(String? accessToken) {
    _accessToken = accessToken;
  }

  /// Clears cached access token.
  static void clearAccessToken() {
    _accessToken = null;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $_accessToken';
    }

    // var token = read(StorageKeys.apiToken);
    // options.headers['Authorization'] = 'Bearer $token';
    log('\x1B[34mREQUEST => [${options.method}] ${options.path}\x1B[0m');
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    String apiPath = response.requestOptions.path;
    String successLog =
        'SUCCESS PATH => [${response.requestOptions.method}] $apiPath (${response.statusCode})';
    log('\x1B[32m$successLog\x1B[0m');
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final method = err.requestOptions.method;
    final path = err.requestOptions.path;
    final statusCode = err.response?.statusCode;

    String errormsg =
        'ERROR PATH => [$method] $path (Status: ${statusCode ?? 'Unknown'})';
    log('\x1B[31m$errormsg\x1B[0m');

    // Handle 401 Unauthorized / Token Expiration if needed
    if (statusCode == 401 || statusCode == 403) {
      log('\x1B[33mAUTH EXPIRED => [$statusCode] $path\x1B[0m');
    }

    return super.onError(err, handler);
  }
}
