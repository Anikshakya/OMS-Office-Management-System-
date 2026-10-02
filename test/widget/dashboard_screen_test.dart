import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oms/screens/dashboard_screen.dart';
import 'package:oms/app_config/app_routes.dart';
import 'package:oms/controllers/app_data_controller.dart';
import 'package:get/get.dart';
import 'package:oms/controllers/user_controller.dart';
import 'package:oms/controllers/app_controller.dart';
import 'package:oms/controllers/theme_controller.dart';
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
    Get.put(AppController());
    final dataController = Get.put(AppDataController());
    Get.put(ThemeController(themeService: _MemoryThemeService()));
    addTearDown(Get.reset);

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.dashboard,
        getPages: [
          GetPage(
            name: AppRoutes.dashboard,
            page: () => const Scaffold(body: DashboardScreen()),
          ),
          GetPage(
            name: AppRoutes.applyLeave,
            page: () => const Scaffold(body: Text('Apply Leave Route')),
          ),
          GetPage(
            name: AppRoutes.appraisal,
            page: () => const Scaffold(body: Text('Appraisal Route')),
          ),
        ],
      ),
    );

    // Wait for animations
    await tester.pumpAndSettle();

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
    final applyLeaveButton = find.widgetWithText(ElevatedButton, 'Apply Leave');
    expect(applyLeaveButton, findsOneWidget);

    // Apply Leave opens as a separate route, not a home tab.
    await tester.tap(applyLeaveButton);
    await tester.pumpAndSettle();
    expect(Get.currentRoute, AppRoutes.applyLeave);
    expect(find.text('Apply Leave Route'), findsOneWidget);
    Get.back();
    await tester.pumpAndSettle();

    // Verify Appraisal button
    final appraisalButton = find.widgetWithText(OutlinedButton, 'Appraisal');
    expect(appraisalButton, findsOneWidget);

    await tester.tap(appraisalButton);
    await tester.pumpAndSettle();
    expect(Get.currentRoute, AppRoutes.appraisal);
    expect(find.text('Appraisal Route'), findsOneWidget);
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
  });
}
