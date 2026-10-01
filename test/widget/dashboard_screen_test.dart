import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oms/screens/dashboard_screen.dart';
import 'package:oms/state/app_state.dart';
import 'package:get/get.dart';
import 'package:oms/controllers/user_controller.dart';
import 'package:oms/controllers/app_controller.dart';
import 'package:flutter/services.dart';

void main() {
  testWidgets('DashboardScreen rendering and interactions', (WidgetTester tester) async {
    const MethodChannel('plugins.flutter.io/path_provider')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      return '.';
    });
    Get.put(UserController());
    Get.put(AppController());
    final appState = AppState();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DashboardScreen(state: appState),
      ),
    ));

    // Wait for animations
    await tester.pumpAndSettle();

    // Verify hero banner
    expect(find.textContaining('Hello, ${appState.currentUser.name}'), findsOneWidget);
    expect(find.textContaining(appState.currentUser.designation), findsOneWidget);

    // Verify Apply Leave button
    final applyLeaveButton = find.widgetWithText(ElevatedButton, 'Apply Leave');
    expect(applyLeaveButton, findsOneWidget);
    
    // Tap Apply Leave and verify state change
    await tester.tap(applyLeaveButton);
    expect(appState.selectedPageIndex, 1);

    // Verify Appraisal button
    final appraisalButton = find.widgetWithText(OutlinedButton, 'Appraisal');
    expect(appraisalButton, findsOneWidget);

    await tester.tap(appraisalButton);
    expect(appState.selectedPageIndex, 3);

    // Verify Employees On Leave section
    expect(find.text('Employees On Leave'), findsOneWidget);
    
    // Tap previous day
    final prevButton = find.byTooltip('Previous Day');
    expect(prevButton, findsOneWidget);
    
    await tester.tap(prevButton);
    await tester.pumpAndSettle();

    // Tap next day
    final nextButton = find.byTooltip('Next Day');
    expect(nextButton, findsOneWidget);

    await tester.tap(nextButton);
    await tester.pumpAndSettle();
  });
}
