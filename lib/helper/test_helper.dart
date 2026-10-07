import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:get_storage/get_storage.dart';
import 'package:oms/api_config/dio_client.dart' show dio;
import 'package:oms/main.dart' as app;
import 'package:oms/services/cache_service.dart' show StorageKeys;

// -----------------------------------------------------------------------------
// Real backend configuration
// -----------------------------------------------------------------------------

/// Optional overrides for the account used by the tests:
///   --dart-define=TEST_EMAIL=you@company.com --dart-define=TEST_PASSWORD=...
/// When omitted, the tests use whatever the login page pre-fills (see
/// lib/screens/login_page.dart), so no credentials are duplicated here.
const String _emailOverride = String.fromEnvironment('TEST_EMAIL');
const String _passwordOverride = String.fromEnvironment('TEST_PASSWORD');

/// The valid test account. Filled in by [launchApp] / [readLoginPagePrefill].
String? _email;
String? _password;

String get testEmail => _email ?? (throw StateError('Call launchApp() first.'));
String get testPassword =>
    _password ?? (throw StateError('Call launchApp() first.'));

/// Real networks are slow (Dio's own timeout is 30 s), so wait generously.
const Duration kApiTimeout = Duration(seconds: 45);

/// One HTTP call the app made, with the status code the server answered.
class RecordedCall {
  RecordedCall({
    required this.method,
    required this.path,
    required this.requestHeaders,
    required this.requestBody,
  });

  final String method;
  final String path;
  final Map<String, dynamic> requestHeaders;
  final dynamic requestBody;

  /// Null until a response (or an error response) arrives.
  int? statusCode;

  /// The decoded JSON the server answered with (Map/List), if any.
  dynamic responseData;
}

/// Dio interceptor that remembers every call the app makes to the real server
/// (request, status code and response body) so tests can assert on them.
class ApiRecorder extends Interceptor {
  final List<RecordedCall> calls = [];

  /// Calls whose path ends with [pathSuffix], e.g. `callsTo('auth/login')`.
  List<RecordedCall> callsTo(String pathSuffix) =>
      calls.where((c) => c.path.endsWith(pathSuffix)).toList();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final call = RecordedCall(
      method: options.method.toUpperCase(),
      path: options.uri.path,
      requestHeaders: Map<String, dynamic>.from(options.headers),
      requestBody: options.data,
    );
    calls.add(call);
    options.extra['recordedCall'] = call;
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final call = response.requestOptions.extra['recordedCall'] as RecordedCall?;
    call?.statusCode = response.statusCode;
    call?.responseData = response.data;
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final call = err.requestOptions.extra['recordedCall'] as RecordedCall?;
    call?.statusCode = err.response?.statusCode;
    call?.responseData = err.response?.data;
    handler.next(err);
  }
}

// -----------------------------------------------------------------------------
// Finders for the screens/widgets used in several tests
// -----------------------------------------------------------------------------

Finder get emailField => find.byType(TextFormField).first;
Finder get passwordField => find.byType(TextFormField).last;
Finder get signInButton => find.text('Sign In');

Finder get loginTitle => find.text('Welcome Back');
Finder get dashboardHeader => find.text('Employees On Leave');

/// "Hello, <name>" banner on the dashboard.
Finder get greeting => find.textContaining('Hello, ');

/// Bottom-navigation item (labels are unique in the app: Home/Leaves/Team/Profile).
Finder navTab(String label) => find.text(label);

/// A text inside the currently open dialog. Needed when the same label also
/// exists behind the dialog (e.g. "Log Out" on the profile page and in its
/// confirmation dialog).
Finder dialogText(String label) =>
    find.descendant(of: find.byType(Dialog), matching: find.text(label));

// -----------------------------------------------------------------------------
// Waiting
// -----------------------------------------------------------------------------

/// Pumps frames (in real time) until [finder] matches something.
///
/// Use this instead of `pumpAndSettle` whenever a spinner is on screen
/// (login button, leave history, logout dialog): a spinner never "settles",
/// so `pumpAndSettle` would just sit there until its 10 minute timeout.
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = kApiTimeout,
  Duration step = const Duration(milliseconds: 100),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (finder.evaluate().isEmpty) {
    if (DateTime.now().isAfter(deadline)) {
      throw TestFailure(
        'Timed out after ${timeout.inSeconds}s waiting for: $finder',
      );
    }
    await tester.pump(step);
  }
}

/// Pumps frames (in real time) until [finder] no longer matches anything.
/// Handy for toasts: let them expire so they can't leak into the next test.
Future<void> pumpUntilGone(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = kApiTimeout,
  Duration step = const Duration(milliseconds: 100),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (finder.evaluate().isNotEmpty) {
    if (DateTime.now().isAfter(deadline)) {
      throw TestFailure(
        'Timed out after ${timeout.inSeconds}s waiting for this to disappear: $finder',
      );
    }
    await tester.pump(step);
  }
}

/// Like `pumpAndSettle`, but fails after [timeout] (default 10 s) with a clear
/// message instead of hanging when something animates forever.
Future<void> settle(
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final deadline = DateTime.now().add(timeout);
  await tester.pump();
  while (tester.binding.hasScheduledFrame) {
    if (DateTime.now().isAfter(deadline)) {
      throw TestFailure(
        'UI did not settle within ${timeout.inSeconds}s - is a spinner or '
        'repeating animation still on screen?',
      );
    }
    await tester.pump(const Duration(milliseconds: 100));
  }
}

// -----------------------------------------------------------------------------
// Interaction (keyboard + scrolling aware)
// -----------------------------------------------------------------------------

/// Closes the on-screen keyboard if a text field currently has focus.
///
/// On a real device/emulator the keyboard shrinks the screen. The login page
/// is a scroll view, so the "Sign In" button can end up outside the visible
/// area and a plain `tester.tap` misses it ("would not hit test").
Future<void> hideKeyboard(WidgetTester tester) async {
  final focused = FocusManager.instance.primaryFocus;
  if (focused == null) return;

  // A text field's FocusNode belongs to a Focus widget *inside* EditableText,
  // so look for EditableText among the ancestors.
  final isTextInput =
      focused.context?.findAncestorWidgetOfExactType<EditableText>() != null;

  focused.unfocus();
  if (isTextInput) {
    // Give the keyboard time to animate away and the layout time to grow back.
    await tester.pump(const Duration(milliseconds: 400));
  }
}

/// Scrolls every scrollable ancestor so [finder] is in the middle of the view.
Future<void> scrollIntoView(WidgetTester tester, Finder finder) async {
  final matches = finder.evaluate();
  if (matches.length != 1) {
    throw TestFailure(
      'Expected exactly one widget for $finder but found ${matches.length}.',
    );
  }
  await Scrollable.ensureVisible(matches.single, alignment: 0.5);
  await tester.pump(const Duration(milliseconds: 100));
}

/// Taps [finder] after making sure nothing (keyboard, scroll offset) hides it.
Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await hideKeyboard(tester);
  await scrollIntoView(tester, finder);
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 100));
}

/// Replaces the text of [field] (empty string clears it).
Future<void> typeInto(WidgetTester tester, Finder field, String text) async {
  await scrollIntoView(tester, field);
  await tester.enterText(field, text);
  await tester.pump(const Duration(milliseconds: 150));
}

// -----------------------------------------------------------------------------
// App lifecycle
// -----------------------------------------------------------------------------

/// Starts the app against the REAL server.
///
/// * Clears local storage first (unless [keepStorage]) so the app starts logged out.
/// * Adds an [ApiRecorder] to the app's global Dio client; nothing else about
///   the network layer is touched.
///
/// Returns the recorder so tests can inspect the calls the app made.
Future<ApiRecorder> launchApp(
  WidgetTester tester, {
  bool keepStorage = false,
}) async {
  final recorder = ApiRecorder();
  dio.interceptors.removeWhere((i) => i is ApiRecorder);
  dio.interceptors.add(recorder); // added last => sees the Authorization header

  Get.reset(); // drop controllers from the previous test
  if (!keepStorage) {
    await GetStorage().erase();
  }

  // `main()` is async (GetStorage.init) - it must be awaited, otherwise the
  // first pump can run before runApp() has been called.
  await app.main();
  return recorder;
}

/// Resolves the valid test account: `--dart-define` overrides if given,
/// otherwise the values the login page pre-fills. Call while the login page is
/// on screen and BEFORE the fields are overwritten.
void resolveCredentials(WidgetTester tester) {
  String textOf(Finder field) => tester
      .widget<EditableText>(
        find.descendant(of: field, matching: find.byType(EditableText)),
      )
      .controller
      .text;

  _email ??= _emailOverride.isNotEmpty ? _emailOverride : textOf(emailField);
  _password ??= _passwordOverride.isNotEmpty
      ? _passwordOverride
      : textOf(passwordField);

  if (testEmail.isEmpty || testPassword.isEmpty) {
    throw StateError(
      'No test account: the login page is not pre-filled. Run with\n'
      '  --dart-define=TEST_EMAIL=<email> --dart-define=TEST_PASSWORD=<password>',
    );
  }
}

/// Types the credentials and presses "Sign In".
Future<void> signIn(
  WidgetTester tester, {
  String? email,
  String? password,
}) async {
  resolveCredentials(tester);
  await typeInto(tester, emailField, email ?? testEmail);
  await typeInto(tester, passwordField, password ?? testPassword);
  await tapVisible(tester, signInButton);
}

/// Launches the app, logs in with the real test account and waits for the dashboard.
Future<ApiRecorder> loginToDashboard(WidgetTester tester) async {
  final api = await launchApp(tester);
  await pumpUntilFound(tester, loginTitle);
  await signIn(tester);
  await pumpUntilFound(tester, dashboardHeader);
  await settle(tester);
  return api;
}
