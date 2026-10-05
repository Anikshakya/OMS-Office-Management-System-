import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:oms/api_config/dio_client.dart' show dio;
import 'package:oms/main.dart' as app;
import 'package:oms/services/cache_service.dart' show StorageKeys;

import 'fake_api.dart';

// -----------------------------------------------------------------------------
// Finders for the screens/widgets used in several tests
// -----------------------------------------------------------------------------

Finder get emailField => find.byType(TextFormField).first;
Finder get passwordField => find.byType(TextFormField).last;
Finder get signInButton => find.text('Sign In');

Finder get loginTitle => find.text('Welcome Back');
Finder get dashboardHeader => find.text('Employees On Leave');

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
  Duration timeout = const Duration(seconds: 20),
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
  Duration timeout = const Duration(seconds: 20),
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
  if (focused?.context?.widget is! EditableText) return;
  focused!.unfocus();
  // Give the keyboard time to animate away and the layout time to grow back.
  await tester.pump(const Duration(milliseconds: 400));
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

/// Starts the real app from scratch with a clean storage and a fake backend.
///
/// Pass [storedToken] to simulate a user who is already logged in.
/// Returns the fake API so tests can inspect the requests the app made.
///
/// To run against the real server instead, delete the `dio.httpClientAdapter`
/// line (the tests that depend on [FakeApiAdapter] data will then fail).
Future<FakeApiAdapter> launchApp(
  WidgetTester tester, {
  String? storedToken,
}) async {
  final api = FakeApiAdapter();
  dio.httpClientAdapter = api;

  Get.reset(); // drop controllers from the previous test
  final storage = GetStorage();
  await storage.erase();
  if (storedToken != null) {
    await storage.write(StorageKeys.apiToken, storedToken);
  }

  // `main()` is async (GetStorage.init) - it must be awaited, otherwise the
  // first pump can run before runApp() has been called.
  await app.main();
  return api;
}

/// Types the credentials and presses "Sign In".
Future<void> signIn(
  WidgetTester tester, {
  String email = FakeApiAdapter.validEmail,
  String password = FakeApiAdapter.validPassword,
}) async {
  await typeInto(tester, emailField, email);
  await typeInto(tester, passwordField, password);
  await tapVisible(tester, signInButton);
}

/// Launches the app, logs in with valid credentials and waits for the dashboard.
Future<FakeApiAdapter> loginToDashboard(WidgetTester tester) async {
  final api = await launchApp(tester);
  await pumpUntilFound(tester, loginTitle);
  await signIn(tester);
  await pumpUntilFound(tester, dashboardHeader);
  await settle(tester);
  return api;
}
