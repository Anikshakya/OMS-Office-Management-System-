import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:integration_test/integration_test.dart';
import 'package:oms/helper/test_helper.dart';
import 'package:oms/services/cache_service.dart' show StorageKeys, read;
import 'package:oms/widgets/common/custom_inputs.dart' show AppSearchField;

/// End-to-end tests for the OMS app against the REAL backend
/// (http://110.44.126.55:8404). There is no fake/mock API in these tests.
///
/// Run on a connected device / emulator:
///   flutter test integration_test/app_test.dart -d <device-id>
///
/// The account is whatever lib/screens/login_page.dart pre-fills. To use a
/// different one:
///   --dart-define=TEST_EMAIL=<email> --dart-define=TEST_PASSWORD=<password>
///
/// Use a dedicated test account: every test really logs in, and the logout
/// tests revoke the session on the server.
///
/// Expected values (token, user name, leave counts, ...) are read from the
/// server's actual responses, so the tests keep working when the data changes.
///
/// Note: the app only calls three endpoints (auth/login, auth/logout,
/// employeeapp/employee-leaves). The Team list and "Apply Leave" use the
/// app's built-in in-memory data, so those tests cover the UI flow only.
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

    // 2. Login (real server) -> Dashboard
    await signIn(tester);
    await pumpUntilFound(tester, dashboardHeader);
    await settle(tester);
    expect(loginTitle, findsNothing);
    expect(find.text('Hello, ${_loginUser(api)['name']}'), findsOneWidget);

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

    // 5. Logout from the profile page (button -> confirmation dialog -> server)
    await tapVisible(tester, navTab('Profile'));
    await pumpUntilFound(tester, find.text('Log Out'));
    await tapVisible(tester, find.text('Log Out'));
    await pumpUntilFound(tester, find.text('Log Out?'));
    await tapVisible(tester, dialogText('Log Out'));

    await pumpUntilFound(tester, loginTitle);
    await settle(tester);
    expect(read(StorageKeys.apiToken), '');

    final logout = api.callsTo('auth/logout').single;
    expect(logout.statusCode, 200);
    expect((logout.responseData as Map)['status'], 'success');
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
      await typeInto(tester, passwordField, 'SomePassw0rd!');
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
      expect(api.callsTo('auth/login'), isEmpty);
    });

    testWidgets('wrong password is rejected by the real server', (
      tester,
    ) async {
      final api = await launchApp(tester);
      await pumpUntilFound(tester, loginTitle);

      await signIn(tester, password: 'definitely-wrong-password-123');

      // AuthController always ends with this generic toast for any non-success
      // answer. Toasts are queued, so the server's own message (if any) shows
      // first and this one a few seconds later.
      final generic = find.text('Login failed. Please check your credentials.');
      await pumpUntilFound(tester, generic);

      expect(loginTitle, findsOneWidget);
      expect(dashboardHeader, findsNothing);
      expect(read(StorageKeys.apiToken), '');

      final call = api.callsTo('auth/login').single;
      final body = call.responseData;
      expect(
        body is Map && body['status'] == 'success',
        isFalse,
        reason: 'server accepted a wrong password (status ${call.statusCode})',
      );

      // Let the toast expire so it can't appear in the next test.
      await pumpUntilGone(tester, generic);
    });

    testWidgets('valid credentials: token, user and dashboard come from the '
        'server response', (tester) async {
      final api = await loginToDashboard(tester);

      final call = api.callsTo('auth/login').single;
      expect(call.method, 'POST');
      expect(call.requestBody['email'], testEmail);
      expect(call.requestBody['password'], testPassword);
      expect(call.statusCode, 200);

      final body = call.responseData as Map;
      expect(body['status'], 'success');

      final token = body['data']['token'] as String;
      expect(token, isNotEmpty);
      expect(read(StorageKeys.apiToken), token);

      final user = _loginUser(api);
      expect(find.text('Hello, ${user['name']}'), findsOneWidget);
      for (final label in ['Home', 'Leaves', 'Team', 'Profile']) {
        expect(navTab(label), findsOneWidget, reason: 'tab "$label"');
      }
    });

    testWidgets('the real session survives an app restart', (tester) async {
      final api = await loginToDashboard(tester);
      final token = read(StorageKeys.apiToken);
      final name = _loginUser(api)['name'];

      // "Kill" the app (unmount everything) but keep the stored session.
      await tester.pumpWidget(const SizedBox.shrink());
      final api2 = await launchApp(tester, keepStorage: true);

      await pumpUntilFound(tester, dashboardHeader); // splash skips login
      await settle(tester);
      expect(loginTitle, findsNothing);
      expect(read(StorageKeys.apiToken), token);
      expect(find.text('Hello, $name'), findsOneWidget);

      // ...and the stored token is still accepted by the real server.
      await tapVisible(tester, navTab('Leaves'));
      await pumpUntilFound(tester, find.text('Leaves in $thisYear'));
      final call = api2.callsTo('employeeapp/employee-leaves').last;
      expect(call.requestHeaders['Authorization'], 'Bearer $token');
      expect(call.statusCode, 200);
    });
  });

  // ---------------------------------------------------------------------------
  // Leaves (data from employeeapp/employee-leaves)
  // ---------------------------------------------------------------------------
  group('Leaves', () {
    testWidgets(
      'history on screen matches the server response and filters work',
      (tester) async {
        final api = await loginToDashboard(tester);
        final token = read(StorageKeys.apiToken);

        await tapVisible(tester, navTab('Leaves'));
        // Shown only after the spinner is gone, i.e. after the response arrived.
        await pumpUntilFound(tester, find.text('Leaves in $thisYear'));
        await settle(tester);

        final call = api.callsTo('employeeapp/employee-leaves').last;
        expect(call.method, 'GET');
        expect(call.requestHeaders['Authorization'], 'Bearer $token');
        expect(call.statusCode, 200);
        expect((call.responseData as Map)['status'], 'success');

        // What the UI is expected to show, computed from the REAL response using
        // the same rules as LeaveController / LeaveHistoryScreen.
        final expected = _expectedLeaves(call, thisYear);
        debugPrint(
          'Server returned ${expected.all} leave(s) for $thisYear: '
          '${expected.pending} pending, ${expected.approved} approved, '
          '${expected.rejected} rejected',
        );

        // Counter badges on the filter pills.
        expect(_pillCount(tester, 'All'), expected.all, reason: 'All badge');
        expect(_pillCount(tester, 'Pending'), expected.pending);
        expect(_pillCount(tester, 'Approved'), expected.approved);
        expect(_pillCount(tester, 'Rejected'), expected.rejected);

        // Each filter shows exactly that many cards (or the empty message).
        final cards = find.textContaining('Reason: ');
        final empty = find.text('No leaves matching filters for $thisYear.');
        final perFilter = {
          'Pending': expected.pending,
          'Approved': expected.approved,
          'Rejected': expected.rejected,
          'All': expected.all,
        };
        for (final entry in perFilter.entries) {
          // `.first`: card status badges reuse labels like "Approved", the pill
          // comes first in the widget tree.
          await tapVisible(tester, find.text(entry.key).first);
          await settle(tester);
          expect(
            cards,
            findsNWidgets(entry.value),
            reason: '${entry.key} cards',
          );
          expect(empty, entry.value == 0 ? findsOneWidget : findsNothing);
        }
      },
    );

    testWidgets('tapping a leave opens its details from the server data', (
      tester,
    ) async {
      final api = await loginToDashboard(tester);

      await tapVisible(tester, navTab('Leaves'));
      await pumpUntilFound(tester, find.text('Leaves in $thisYear'));
      await settle(tester);

      final expected = _expectedLeaves(
        api.callsTo('employeeapp/employee-leaves').last,
        thisYear,
      );
      if (expected.all == 0) {
        debugPrint('No leaves for $thisYear on this account: nothing to open.');
        return;
      }

      // Open the first card; which leave it is doesn't matter, it must exist
      // in the server response and its reason must match.
      await tapVisible(tester, find.textContaining('Reason: ').first);
      await pumpUntilFound(tester, find.byType(Dialog));
      await settle(tester);

      final reference = find.descendant(
        of: find.byType(Dialog),
        matching: find.textContaining('Request Reference: '),
      );
      final shownId = tester
          .widget<Text>(reference)
          .data!
          .split('Request Reference: ')
          .last;
      final leave = expected.thisYear.firstWhere(
        (l) => '${l['employee_leave_id']}' == shownId,
        orElse: () => throw TestFailure(
          'Dialog shows request "$shownId" which is not in the server response',
        ),
      );

      final reason = '${leave['leave_reason'] ?? ''}';
      if (reason.isNotEmpty) {
        expect(dialogText(reason), findsOneWidget);
      }

      await tapVisible(tester, dialogText('Close'));
      await pumpUntilGone(tester, find.byType(Dialog));
    });

    // NOTE: "Apply Leave" only updates in-memory data in this codebase
    // (AppDataController.submitLeaveRequest) - it makes no API call - so this
    // checks the UI flow only.
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
  // Team: the logged-in (real) user is inserted into the personnel list
  // ---------------------------------------------------------------------------
  testWidgets('Team: search finds the real logged-in user', (tester) async {
    final api = await loginToDashboard(tester);
    final name = '${_loginUser(api)['name']}';

    await tapVisible(tester, navTab('Team'));
    await pumpUntilFound(tester, find.textContaining('Personnel ('));

    final search = find.descendant(
      of: find.byType(AppSearchField),
      matching: find.byType(TextFormField),
    );

    await typeInto(tester, search, name);
    await settle(tester);
    expect(find.text(name), findsWidgets);
    expect(find.text('Personnel (0)'), findsNothing);

    await typeInto(tester, search, 'zzz-no-such-person-zzz');
    await settle(tester);
    expect(find.text('Personnel (0)'), findsOneWidget);
  });

  // ---------------------------------------------------------------------------
  // Profile
  // ---------------------------------------------------------------------------
  group('Profile', () {
    testWidgets('shows the logged-in user from the login response', (
      tester,
    ) async {
      final api = await loginToDashboard(tester);
      final user = _loginUser(api);

      await tapVisible(tester, navTab('Profile'));
      await pumpUntilFound(tester, find.text('Edit Profile'));

      expect(find.text('${user['name']}'), findsWidgets);
      // Header shows "<ROLE> • <department>"; role comes from the server.
      final role = '${user['role'] ?? ''}';
      if (role.isNotEmpty) {
        expect(find.textContaining(role.toUpperCase()), findsWidgets);
      }
    });

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
      final token = read(StorageKeys.apiToken);
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

      expect(read(StorageKeys.apiToken), token);
      expect(api.callsTo('auth/logout'), isEmpty);
      expect(find.text('Edit Profile'), findsOneWidget); // still on Profile
    });
  });
}

// -----------------------------------------------------------------------------
// Helpers that read the REAL server responses recorded by ApiRecorder
// -----------------------------------------------------------------------------

/// `data.user` from the real `auth/login` response.
Map<String, dynamic> _loginUser(ApiRecorder api) {
  final body = api.callsTo('auth/login').single.responseData as Map;
  return Map<String, dynamic>.from(body['data']['user'] as Map);
}

/// Leaves from the real `employee-leaves` response that the screen shows for
/// [year], using the same rules as LeaveController / LeaveHistoryScreen:
/// grouped by the year of `start_date`, status 0 = pending, 1 = approved,
/// 2 = rejected (anything else is treated as pending).
class _ExpectedLeaves {
  _ExpectedLeaves(this.thisYear);

  final List<Map<String, dynamic>> thisYear;

  int get all => thisYear.length;
  int get pending => _count('pending');
  int get approved => _count('approved');
  int get rejected => _count('rejected');

  static String _status(Map<String, dynamic> leave) {
    final status = leave['leave_status'];
    if (status == 1) return 'approved';
    if (status == 2) return 'rejected';
    return 'pending';
  }

  int _count(String status) =>
      thisYear.where((l) => _status(l) == status).length;
}

_ExpectedLeaves _expectedLeaves(RecordedCall call, int year) {
  final data = (call.responseData as Map)['data'] as List;
  final inYear = data.map((e) => Map<String, dynamic>.from(e as Map)).where((
    leave,
  ) {
    final start = DateTime.tryParse('${leave['start_date'] ?? ''}');
    return (start ?? DateTime.now()).year == year;
  }).toList();
  return _ExpectedLeaves(inYear);
}

/// The number shown in the badge of a filter pill ("All", "Pending", ...).
int _pillCount(WidgetTester tester, String label) {
  // The pill's own Row is the nearest Row around its label.
  final pill = find
      .ancestor(of: find.text(label).first, matching: find.byType(Row))
      .first;
  final texts = find
      .descendant(of: pill, matching: find.byType(Text))
      .evaluate()
      .map((e) => (e.widget as Text).data)
      .toList();
  return int.parse(texts.last!);
}
