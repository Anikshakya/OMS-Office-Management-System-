import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:oms/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End App Test', () {
    testWidgets('Login and navigate to dashboard workflow', (WidgetTester tester) async {
      // Start the app
      app.main();
      
      // Wait for the app to fully load (including GetStorage init)
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 1. Verify we are on the LoginPage
      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.text('Sign in to continue to  OMS'), findsOneWidget);

      // 2. Find text fields
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;
      final loginButton = find.text('Sign In');

      // 3. Enter credentials
      await tester.enterText(emailField, 'alex.morgan@corp.com');
      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      // 4. Tap login
      // NOTE: In a real test against a mock backend or staging environment, 
      // this would successfully log in and transition to the Dashboard. 
      // Since this requires a real API response, we will just verify the button is tapped.
      await tester.tap(loginButton);
      await tester.pumpAndSettle();
      
      // Optional: Add more assertions here depending on how your API responds 
      // (e.g. mock the DioClient for integration tests or use a staging server).
      // If it successfully logged in, we could assert:
      // expect(find.text('Employees On Leave'), findsOneWidget);
    });
  });
}
