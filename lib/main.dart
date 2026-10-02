import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:oms/screens/dashboard.dart';

import 'app_config/app_routes.dart';
import 'theme/app_theme.dart';

import 'screens/login_page.dart';
import 'screens/apply_leave_screen.dart';
import 'screens/appraisal_screen.dart';
import 'screens/splash_screen.dart';

import 'controllers/user_controller.dart';
import 'controllers/app_controller.dart';
import 'controllers/app_data_controller.dart';
import 'controllers/leave_controller.dart';
import 'controllers/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  Get.put(UserController());
  Get.put(AppController());
  Get.put(LeaveController());
  Get.put(AppDataController());
  Get.put(ThemeController());

  runApp(const OmsApp());
}

// =============================================================================
// APP
// =============================================================================

class OmsApp extends StatefulWidget {
  const OmsApp({super.key});

  @override
  State<OmsApp> createState() => _OmsAppState();
}

class _OmsAppState extends State<OmsApp> {
  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        title: 'Nexus Office Management System',
        debugShowCheckedModeBanner: false,
        navigatorKey: Get.key,

        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.themeMode.value,

        defaultTransition: Transition.noTransition,

        home: const SplashScreen(),

        getPages: [
          GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
          GetPage(name: AppRoutes.login, page: () => const LoginPage()),
          GetPage(
            name: AppRoutes.dashboard,
            page: () => const Dashboard(),
          ),
          GetPage(
            name: AppRoutes.applyLeave,
            page: () => ApplyLeaveScreen(),
          ),
          GetPage(
            name: AppRoutes.appraisal,
            page: () => AppraisalScreen(),
          ),
        ],
      ),
    );
  }
}


