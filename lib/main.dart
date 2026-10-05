import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'controllers/app_controller.dart';
import 'controllers/app_data_controller.dart';
import 'controllers/leave_controller.dart';
import 'controllers/theme_controller.dart';
import 'controllers/user_controller.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

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
        title: 'Office Management System',
        debugShowCheckedModeBanner: false,
        navigatorKey: Get.key,

        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.themeMode.value,

        defaultTransition: Transition.rightToLeftWithFade,
        transitionDuration: const Duration(milliseconds: 600),

        home: const SplashScreen(),
      ),
    );
  }
}

