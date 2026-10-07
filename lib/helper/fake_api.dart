import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Replaces Dio's real network layer so the integration tests are fast,
/// deterministic and don't need the live server (http://110.44.126.55:8404).
///
/// Installed automatically by `launchApp()` unless the tests are started with
/// `--dart-define=REAL_API=true` (see support/test_helpers.dart).
///
/// It answers the three endpoints the app uses:
///   POST auth/login
///   POST auth/logout
///   GET  employeeapp/employee-leaves
class FakeApiAdapter implements HttpClientAdapter {
  FakeApiAdapter({this.latency = const Duration(milliseconds: 400)});

  // ---- Test data (referenced from the tests) --------------------------------
  static const validEmail = 'employee@test.com';
  static const validPassword = 'Passw0rd!23';
  static const token = 'fake-test-token';
  static const userName = 'Test Employee';
  static const invalidCredentialsMessage = 'Invalid email or password';
  static const approvedLeaveReason = 'Family function';
  static const pendingLeaveReason = 'Dentist appointment';

  /// Simulated server latency, so loading states are really exercised.
  final Duration latency;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final method = options.method.toUpperCase();
    final path = options.uri.path;

    await Future<void>.delayed(latency);

    if (method == 'POST' && path.endsWith('auth/login')) {
      return _login(options.data);
    }
    if (method == 'POST' && path.endsWith('auth/logout')) {
      return _json({'status': 'success', 'message': 'Logged out'});
    }
    if (method == 'GET' && path.endsWith('employeeapp/employee-leaves')) {
      return _json(_leaves());
    }

    return _json({
      'status': 'error',
      'message': 'FakeApiAdapter has no route for $method $path',
    }, 404);
  }

  @override
  void close({bool force = false}) {}

  // ---- Responses ------------------------------------------------------------

  ResponseBody _login(dynamic body) {
    final email = body is Map ? body['email'] : null;
    final password = body is Map ? body['password'] : null;

    if (email == validEmail && password == validPassword) {
      return _json({
        'status': 'success',
        'message': 'Login successful',
        'data': {
          'token': token,
          'user': {
            'id': 101,
            'name': userName,
            'email': validEmail,
            'role': 'employee',
            'profile_image': null,
            'active': 1,
          },
        },
      });
    }

    return _json({
      'status': 'error',
      'message': invalidCredentialsMessage,
    }, 401);
  }

  Map<String, dynamic> _leaves() {
    // Dates are relative to "today" so the entries always fall in the year the
    // Leaves screen shows by default.
    final now = DateTime.now();
    String date(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final today = date(now);

    return {
      'status': 'success',
      'data': [
        {
          'employee_leave_id': 9001,
          'employee_id': 101,
          'leave_id': 1, // Annual Leave
          'leave_status': 1, // Approved
          'start_date': today,
          'end_date': today,
          'total_days': '1',
          'leave_duration_type': 0,
          'leave_reason': approvedLeaveReason,
          'applied_at': today,
          'hr_remarks': null,
          'supervisor_remarks': null,
          'supervisor_id_cc': null,
        },
        {
          'employee_leave_id': 9002,
          'employee_id': 101,
          'leave_id': 2, // Sick Leave
          'leave_status': 0, // Pending ("Awaiting" in the UI)
          'start_date': today,
          'end_date': today,
          'total_days': '1',
          'leave_duration_type': 0,
          'leave_reason': pendingLeaveReason,
          'applied_at': today,
          'hr_remarks': null,
          'supervisor_remarks': null,
          'supervisor_id_cc': null,
        },
      ],
    };
  }

  ResponseBody _json(Map<String, dynamic> body, [int statusCode = 200]) {
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}
