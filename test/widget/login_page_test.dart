import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:oms/screens/login_page.dart';

void main() {
  testWidgets('LoginPage rendering and validation test', (WidgetTester tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: LoginPage()));

    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.text('Sign in to continue to  OMS'), findsOneWidget);
    
    // Find text fields
    final textFields = find.byType(TextFormField);
    expect(textFields, findsNWidgets(2)); // Email and Password

    // Find Login button
    final loginButton = find.text('Sign In');
    expect(loginButton, findsOneWidget);

    // Tap login without entering data
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    // Check for validation errors
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);

    // Enter invalid email
    await tester.enterText(textFields.first, 'invalid_email');
    await tester.tap(loginButton);
    await tester.pump();

    expect(find.text('Please enter a valid email'), findsOneWidget);

    // Enter valid email and short password
    await tester.enterText(textFields.first, 'test@example.com');
    await tester.enterText(textFields.last, '123');
    await tester.tap(loginButton);
    await tester.pump();

    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
  });
}
