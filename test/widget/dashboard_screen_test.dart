import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oms/screens/dashboard.dart';
import 'package:oms/controllers/app_data_controller.dart';
import 'package:get/get.dart';
import 'package:oms/controllers/user_controller.dart';
import 'package:oms/controllers/app_controller.dart';
import 'package:oms/controllers/theme_controller.dart';
import 'package:oms/models/toast_notification.dart';
import 'package:oms/services/theme_service.dart';
import 'package:flutter/services.dart';

class _MemoryThemeService implements ThemeService {
  @override
  ThemeMode loadThemeMode() => ThemeMode.dark;

  @override
  Future<void> saveThemeMode(ThemeMode mode) async {}
}

void main() {
  testWidgets('DashboardScreen rendering and interactions', (
    WidgetTester tester,
  ) async {
    const MethodChannel(
      'plugins.flutter.io/path_provider',
      // ignore: deprecated_member_use
    ).setMockMethodCallHandler((MethodCall methodCall) async {
      return '.';
    });
    Get.put(UserController());
    final appController = Get.put(AppController());
    final dataController = Get.put(AppDataController());
    Get.put(ThemeController(themeService: _MemoryThemeService()));
    addTearDown(Get.reset);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Dashboard(),
      ),
    );

    // Wait for animations
    await tester.pumpAndSettle();
    expect(Get.key.currentState, isNotNull);

    // Verify hero banner
    expect(
      find.textContaining('Hello, ${dataController.currentUser.name}'),
      findsOneWidget,
    );
    expect(
      find.textContaining(dataController.currentUser.designation),
      findsOneWidget,
    );

    // Verify Apply Leave button
    final applyLeaveButton = find.ancestor(of: find.text('Apply Leave'), matching: find.byType(InkWell));
    expect(applyLeaveButton, findsOneWidget);

    // Apply Leave opens as a separate route, not a home tab.
    await tester.tap(applyLeaveButton);
    await tester.pumpAndSettle();
    expect(find.text('Apply Leave'), findsWidgets); // Depends on what ApplyLeaveScreen has, but it's loaded because we navigate to it.
    Get.back();
    await tester.pumpAndSettle();

    // Verify Appraisal button
    expect(find.text('View Appraisal'), findsOneWidget);

    await tester.tap(find.text('View Appraisal'));
    await tester.pumpAndSettle();
    expect(find.text('Submit Appraisal'), findsWidgets); // Appraisalscreen title or something
    Get.back();
    await tester.pumpAndSettle();

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

    appController.showToast('Dismissible', 'Swipe to dismiss', ToastType.info);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Swipe to dismiss'), findsOneWidget);

    await tester.drag(find.text('Swipe to dismiss'), const Offset(400, 0));
    await tester.pumpAndSettle();
    expect(find.text('Swipe to dismiss'), findsNothing);
  });
}
