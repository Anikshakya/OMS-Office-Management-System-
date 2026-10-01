import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oms/api_config/api_repo.dart';

void main() {
  group('ApiRepo Tests', () {
    test('handleApiError parses DioException without response', () {
      final requestOptions = RequestOptions(path: '');
      final error = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.connectionTimeout,
      );

      final result = ApiRepo.handleApiError(error: error, showToast: false);
      expect(result, 'Connection timeout. Please check your network.');
    });

    test('handleApiError parses DioException with response message', () {
      final requestOptions = RequestOptions(path: '');
      final error = DioException(
        requestOptions: requestOptions,
        response: Response(
          requestOptions: requestOptions,
          data: {'message': 'Invalid credentials'},
        ),
      );

      final result = ApiRepo.handleApiError(error: error, showToast: false);
      expect(result.toString(), contains('Invalid credentials'));
    });

    test('handleApiError handles generic exception', () {
      final error = Exception('Something went wrong');

      final result = ApiRepo.handleApiError(error: error, showToast: false);
      expect(result, 'Something went wrong');
    });

    test('handleApiError handles string error', () {
      final result = ApiRepo.handleApiError(error: 'String error', showToast: false);
      expect(result, 'String error');
    });
  });
}
