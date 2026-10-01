import 'package:flutter/material.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'widgets/navigation/responsive_navigation.dart';
import 'widgets/common/custom_toast.dart';
import 'screens/dashboard_screen.dart';
import 'screens/apply_leave_screen.dart';
import 'screens/employee_profile_screen.dart';
import 'screens/appraisal_screen.dart';
import 'screens/leave_history_screen.dart';
import 'screens/employee_list_screen.dart';
import 'screens/employees_on_leave_today_screen.dart';

void main() {
  runApp(const OmsApp());
}

class OmsApp extends StatefulWidget {
  const OmsApp({super.key});

  @override
  State<OmsApp> createState() => _OmsAppState();
}

class _OmsAppState extends State<OmsApp> {
  final AppState _appState = AppState();

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _appState,
      builder: (context, child) {
        return MaterialApp(
          title: 'Nexus Office Management System',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _appState.themeMode,
          home: Stack(
            children: [
              ResponsiveNavigationShell(
                state: _appState,
                body: _buildCurrentPage(_appState.selectedPageIndex),
              ),
              ToastOverlayRenderer(
                toasts: _appState.toasts,
                onDismiss: _appState.dismissToast,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrentPage(int index) {
    switch (index) {
      case 0:
        return DashboardScreen(state: _appState);
      case 1:
        return ApplyLeaveScreen(state: _appState);
      case 2:
        return EmployeeProfileScreen(state: _appState);
      case 3:
        return AppraisalScreen(state: _appState);
      case 4:
        return LeaveHistoryScreen(state: _appState);
      case 5:
        return EmployeeListScreen(state: _appState);
      case 6:
        return EmployeesOnLeaveTodayScreen(state: _appState);
      default:
        return DashboardScreen(state: _appState);
    }
  }
}
