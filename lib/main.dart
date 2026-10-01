import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'services/cache_service.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/login_page.dart';
import 'screens/dashboard_screen.dart';
import 'screens/apply_leave_screen.dart';
import 'screens/employee_profile_screen.dart';
import 'screens/appraisal_screen.dart';
import 'screens/leave_history_screen.dart';
import 'screens/employee_list_screen.dart';
import 'screens/employees_on_leave_today_screen.dart';
import 'widgets/common/custom_toast.dart';
import 'widgets/navigation/responsive_navigation.dart';

import 'package:get/get.dart';
import 'controllers/user_controller.dart';
import 'controllers/app_controller.dart';
import 'controllers/leave_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  Get.put(UserController());
  Get.put(AppController());
  Get.put(LeaveController());
  appState = AppState();
  runApp(const OmsApp());
}

class OmsApp extends StatefulWidget {
  const OmsApp({super.key});

  @override
  State<OmsApp> createState() => _OmsAppState();
}

late final AppState appState;

Widget buildCurrentPage(int index) {
  final pageBuilders = <Widget Function()>[
    () => DashboardScreen(state: appState),
    () => ApplyLeaveScreen(state: appState),
    () => EmployeeProfileScreen(state: appState),
    () => AppraisalScreen(state: appState),
    () => LeaveHistoryScreen(state: appState),
    () => EmployeeListScreen(state: appState),
    () => EmployeesOnLeaveTodayScreen(state: appState),
  ];

  return index >= 0 && index < pageBuilders.length
      ? pageBuilders[index]()
      : pageBuilders.first();
}

class AuthenticatedHome extends StatelessWidget {
  const AuthenticatedHome({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    return Obx(() => Stack(
      children: [
        ResponsiveNavigationShell(
          state: appState,
          body: buildCurrentPage(appController.selectedPageIndex.value),
        ),
        ToastOverlayRenderer(
          toasts: appController.toasts,
          onDismiss: appController.dismissToast,
        ),
      ],
    ));
  }
}

class _OmsAppState extends State<OmsApp> {
  @override
  void dispose() {
    appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    return Obx(() => GetMaterialApp(
      title: 'Nexus Office Management System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: appController.themeMode.value,
      home: read(StorageKeys.apiToken) != ""
          ? const AuthenticatedHome()
          : const LoginPage(),
    ));
  }
}
