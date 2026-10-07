import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigation, ExtensionDialog;
import 'package:oms/screens/login_page.dart';
import 'package:oms/services/cache_service.dart';
import 'package:oms/theme/app_colors.dart';

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

    if (statusCode == 401 || statusCode == 403) {
      log('\x1B[33mAUTH EXPIRED => [$statusCode] $path\x1B[0m');

      if (!Get.isDialogOpen!) {
        Get.dialog(
          PopScope(
            canPop: false,
            child: AlertDialog(
              backgroundColor: Theme.of(Get.context!).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              title: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      color: Colors.orange,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Session Expired',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              content: const Text(
                'Your session has expired. Please log in again to continue.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Close the dialog first.
                      if (Get.isDialogOpen ?? false) {
                        Get.back();
                      }

                      // Clear authentication/session data here.
                      clearAllData();
                      clearAccessToken();
                      Get.offAll(() => const LoginPage());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Go to Login',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          barrierDismissible: false,
          barrierColor: Colors.black.withValues(alpha: 0.65),
        );
      }
    }

    return super.onError(err, handler);
  }
}
