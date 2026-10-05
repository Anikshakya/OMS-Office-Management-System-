import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:integration_test/integration_test.dart';
import 'package:oms/helper/fake_api.dart';
import 'package:oms/helper/test_helper.dart';
import 'package:oms/services/cache_service.dart' show StorageKeys, read;
import 'package:oms/widgets/common/custom_inputs.dart' show AppSearchField;

/// End-to-end tests for the OMS app.
///
/// Run on a connected device / emulator:
///   flutter test integration_test/app_test.dart -d <device-id>
///
/// The network layer is replaced by [FakeApiAdapter] (see support/), so the
/// tests don't need the real server and always see the same data.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // A tap that misses its target is a test bug: fail right there with the
  // "would not hit test" message instead of a confusing failure further down.
  WidgetController.hitTestWarningShouldBeFatal = true;

  setUpAll(() async {
    await GetStorage.init();
  });

  tearDownAll(() async {
    await GetStorage().erase();
    Get.reset();
  });

  final thisYear = DateTime.now().year;

  // ---------------------------------------------------------------------------
  // Full journey (the original "Startup, Login, Navigation, Logout" scenario)
  // ---------------------------------------------------------------------------
  testWidgets('Full workflow: startup, login, navigation and logout', (
    tester,
  ) async {
    final api = await launchApp(tester);

    // 1. Splash -> Login (storage is empty)
    await pumpUntilFound(tester, loginTitle);
    expect(find.text('Sign in to your OMS workspace'), findsOneWidget);

    // 2. Login -> Dashboard
    await signIn(tester);
    await pumpUntilFound(tester, dashboardHeader);
    await settle(tester);
    expect(loginTitle, findsNothing);
    expect(find.text('Hello, ${FakeApiAdapter.userName}'), findsOneWidget);

    // 3. "Apply Leave" opens a separate full-screen page ON TOP of the
    //    dashboard (Get.to), so the bottom navigation is hidden until we go back.
    await tapVisible(tester, find.text('Apply Leave'));
    await settle(tester);
    expect(find.widgetWithText(AppBar, 'Apply Leave'), findsOneWidget);
    await tester.pageBack();
    await settle(tester);
    expect(dashboardHeader, findsOneWidget);

    // 4. Bottom navigation
    await tapVisible(tester, navTab('Leaves'));
    await pumpUntilFound(tester, find.text('Leaves in $thisYear'));

    await tapVisible(tester, navTab('Team'));
    await pumpUntilFound(tester, find.textContaining('Personnel ('));

    await tapVisible(tester, navTab('Profile'));
    await pumpUntilFound(tester, find.text('Edit Profile'));

    await tapVisible(tester, navTab('Home'));
    await pumpUntilFound(tester, dashboardHeader);

    // 5. Logout from the profile page (button -> confirmation dialog)
    await tapVisible(tester, navTab('Profile'));
    await pumpUntilFound(tester, find.text('Log Out'));
    await tapVisible(tester, find.text('Log Out'));
    await pumpUntilFound(tester, find.text('Log Out?'));
    await tapVisible(tester, dialogText('Log Out'));

    await pumpUntilFound(tester, loginTitle);
    await settle(tester);
    expect(read(StorageKeys.apiToken), '');
    expect(api.requestsTo('auth/logout'), hasLength(1));
  });

  // ---------------------------------------------------------------------------
  // Login
  // ---------------------------------------------------------------------------
  group('Login', () {
    testWidgets('validates empty, malformed and too-short input', (
      tester,
    ) async {
      final api = await launchApp(tester);
      await pumpUntilFound(tester, loginTitle);
      expect(find.byType(TextFormField), findsNWidgets(2));

      // The page pre-fills credentials, so clear them first.
      await typeInto(tester, emailField, '');
      await typeInto(tester, passwordField, '');
      await tapVisible(tester, signInButton);
      await settle(tester);
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);

      await typeInto(tester, emailField, 'not-an-email');
      await typeInto(tester, passwordField, FakeApiAdapter.validPassword);
      await tapVisible(tester, signInButton);
      await settle(tester);
      expect(find.text('Please enter a valid email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsNothing);

      await typeInto(tester, emailField, 'user@example.com');
      await typeInto(tester, passwordField, '123');
      await tapVisible(tester, signInButton);
      await settle(tester);
      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
      expect(find.text('Please enter a valid email'), findsNothing);

      // Client-side validation must stop the request from being sent.
      expect(api.requestsTo('auth/login'), isEmpty);
    });

    testWidgets('wrong credentials show an error and stay on the login page', (
      tester,
    ) async {
      final api = await launchApp(tester);
      await pumpUntilFound(tester, loginTitle);

      await signIn(tester, password: 'WrongPassword1');

      // AuthController shows two toasts: the server message, then a generic one.
      await pumpUntilFound(
        tester,
        find.text(FakeApiAdapter.invalidCredentialsMessage),
      );
      expect(loginTitle, findsOneWidget);
      expect(dashboardHeader, findsNothing);
      expect(read(StorageKeys.apiToken), '');
      expect(api.requestsTo('auth/login'), hasLength(1));

      // Let both toasts expire so they can't appear in the next test.
      final generic = find.text('Login failed. Please check your credentials.');
      await pumpUntilFound(tester, generic);
      await pumpUntilGone(tester, generic);
    });

    testWidgets('valid credentials store the token and open the dashboard', (
      tester,
    ) async {
      final api = await loginToDashboard(tester);

      expect(read(StorageKeys.apiToken), FakeApiAdapter.token);
      expect(find.text('Hello, ${FakeApiAdapter.userName}'), findsOneWidget);
      for (final label in ['Home', 'Leaves', 'Team', 'Profile']) {
        expect(navTab(label), findsOneWidget, reason: 'tab "$label"');
      }

      final loginCall = api.requestsTo('auth/login').single;
      expect(loginCall.body['email'], FakeApiAdapter.validEmail);
      expect(loginCall.body['password'], FakeApiAdapter.validPassword);
    });

    testWidgets('a stored token skips the login page', (tester) async {
      await launchApp(tester, storedToken: 'already-logged-in');

      await pumpUntilFound(tester, dashboardHeader);
      expect(loginTitle, findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // Leaves
  // ---------------------------------------------------------------------------
  group('Leaves', () {
    testWidgets('history is loaded from the API and can be filtered', (
      tester,
    ) async {
      final api = await loginToDashboard(tester);

      await tapVisible(tester, navTab('Leaves'));
      await pumpUntilFound(tester, find.text('Leaves in $thisYear'));
      await settle(tester);

      final approved = find.text(
        'Reason: ${FakeApiAdapter.approvedLeaveReason}',
      );
      final pending = find.text('Reason: ${FakeApiAdapter.pendingLeaveReason}');
      expect(approved, findsOneWidget);
      expect(pending, findsOneWidget);

      // The request carried the token that the login stored.
      final call = api.requestsTo('employeeapp/employee-leaves').last;
      expect(call.headers['Authorization'], 'Bearer ${FakeApiAdapter.token}');

      await tapVisible(tester, find.text('Pending'));
      await settle(tester);
      expect(pending, findsOneWidget);
      expect(approved, findsNothing);

      await tapVisible(tester, find.text('All'));
      await settle(tester);
      expect(approved, findsOneWidget);
      expect(pending, findsOneWidget);
    });

    testWidgets('Apply Leave: submitting returns to the Leaves tab', (
      tester,
    ) async {
      await loginToDashboard(tester);

      await tapVisible(tester, find.text('Apply Leave'));
      await settle(tester);
      expect(find.widgetWithText(AppBar, 'Apply Leave'), findsOneWidget);

      // Everything is pre-filled with valid defaults, so just submit.
      await tapVisible(tester, find.textContaining('Leave Request'));
      await pumpUntilFound(tester, find.text('Leave Applied!'));
      await pumpUntilFound(tester, find.text('Leaves in $thisYear'));
      expect(find.widgetWithText(AppBar, 'Apply Leave'), findsNothing);

      // Let the success toast expire so it can't appear in the next test.
      await pumpUntilGone(tester, find.text('Leave Applied!'));
    });
  });

  // ---------------------------------------------------------------------------
  // Team
  // ---------------------------------------------------------------------------
  testWidgets('Team: search filters the personnel list', (tester) async {
    await loginToDashboard(tester);

    await tapVisible(tester, navTab('Team'));
    await pumpUntilFound(tester, find.textContaining('Personnel ('));

    final search = find.descendant(
      of: find.byType(AppSearchField),
      matching: find.byType(TextFormField),
    );

    await typeInto(tester, search, 'Sarah');
    await settle(tester);
    expect(find.text('Personnel (1)'), findsOneWidget);
    expect(find.text('Sarah Jenkins'), findsWidgets);
    expect(find.text('Marcus Vance'), findsNothing);

    await typeInto(tester, search, 'zzz-no-such-person');
    await settle(tester);
    expect(find.text('Personnel (0)'), findsOneWidget);
  });

  // ---------------------------------------------------------------------------
  // Profile
  // ---------------------------------------------------------------------------
  group('Profile', () {
    testWidgets('theme switch toggles between dark and light mode', (
      tester,
    ) async {
      await loginToDashboard(tester);
      await tapVisible(tester, navTab('Profile'));
      await pumpUntilFound(tester, find.text('Dark Mode Active')); // default

      await tapVisible(tester, find.byType(Switch));
      await settle(tester);
      expect(find.text('Light Mode Active'), findsOneWidget);
      expect(find.text('Dark Mode Active'), findsNothing);

      await tapVisible(tester, find.byType(Switch));
      await settle(tester);
      expect(find.text('Dark Mode Active'), findsOneWidget);
    });

    testWidgets('Cancel in the logout dialog keeps the user signed in', (
      tester,
    ) async {
      final api = await loginToDashboard(tester);
      await tapVisible(tester, navTab('Profile'));
      await pumpUntilFound(tester, find.text('Log Out'));

      await tapVisible(tester, find.text('Log Out'));
      await pumpUntilFound(tester, find.text('Log Out?'));
      expect(
        find.text('Are you sure you want to log out of your account?'),
        findsOneWidget,
      );

      await tapVisible(tester, dialogText('Cancel'));
      await pumpUntilGone(tester, find.text('Log Out?'));
      await settle(tester);

      expect(read(StorageKeys.apiToken), FakeApiAdapter.token);
      expect(api.requestsTo('auth/logout'), isEmpty);
      expect(find.text('Edit Profile'), findsOneWidget); // still on Profile
    });
  });
}
