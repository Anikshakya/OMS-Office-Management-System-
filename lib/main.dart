import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:oms/models/toast_notification.dart';

import 'app_config/app_routes.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

import 'screens/login_page.dart';
import 'screens/dashboard_screen.dart';
import 'screens/apply_leave_screen.dart';
import 'screens/employee_profile_screen.dart';
import 'screens/appraisal_screen.dart';
import 'screens/leave_history_screen.dart';
import 'screens/employee_list_screen.dart';
import 'screens/employees_on_leave_today_screen.dart';
import 'screens/splash_screen.dart';

import 'widgets/common/custom_toast.dart';
import 'widgets/common/custom_buttons.dart';

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

        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.themeMode.value,

        defaultTransition: Transition.noTransition,

        initialRoute: AppRoutes.splash,

        getPages: [
          GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
          GetPage(name: AppRoutes.login, page: () => const LoginPage()),
          GetPage(
            name: AppRoutes.dashboard,
            page: () => const AuthenticatedHome(),
          ),
          GetPage(
            name: AppRoutes.applyLeave,
            page: () => const AuthenticatedTaskPage(body: ApplyLeaveScreen()),
          ),
          GetPage(
            name: AppRoutes.appraisal,
            page: () => const AuthenticatedTaskPage(body: AppraisalScreen()),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// AUTHENTICATED HOME
// =============================================================================

class AuthenticatedHome extends StatefulWidget {
  const AuthenticatedHome({super.key});

  @override
  State<AuthenticatedHome> createState() => _AuthenticatedHomeState();
}

class _AuthenticatedHomeState extends State<AuthenticatedHome> {
  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  static const _tabs = [
    _HomeTab(
      pageIndex: 0,
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    _HomeTab(
      pageIndex: 4,
      label: 'Leaves',
      icon: Icons.history_outlined,
      activeIcon: Icons.history_rounded,
    ),
    _HomeTab(
      pageIndex: 5,
      label: 'Team',
      icon: Icons.groups_outlined,
      activeIcon: Icons.groups_rounded,
    ),
    _HomeTab(
      pageIndex: 2,
      label: 'Profile',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  static const double _navigationHeight = 68;

  static const _homePageIds = [0, 4, 5, 2, 6];

  // ---------------------------------------------------------------------------
  // Pages
  // ---------------------------------------------------------------------------

  final _pages = const <Widget>[
    DashboardScreen(),
    LeaveHistoryScreen(),
    EmployeeListScreen(),
    EmployeeProfileScreen(),
    EmployeesOnLeaveTodayScreen(),
  ];

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();

    return Obx(() {
      final pageIndex = _homePageIds.indexOf(
        appController.selectedPageIndex.value,
      );
      final stackIndex = pageIndex < 0 ? 0 : pageIndex;

      return Scaffold(
        // ---------------------------------------------------------------------
        // TOP APP BAR
        // ---------------------------------------------------------------------
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildTopAppBar(context, appController),
        ),

        // ---------------------------------------------------------------------
        // BODY
        // ---------------------------------------------------------------------
        body: Stack(
          fit: StackFit.expand,
          children: [
            IndexedStack(index: stackIndex, children: _pages),

            // ---------------------------------------------------------------
            // FLOATING BOTTOM NAVIGATION
            // ---------------------------------------------------------------
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildFloatingNavigation(context, appController),
            ),

            // ---------------------------------------------------------------
            // TOAST OVERLAY
            // ---------------------------------------------------------------
            ToastOverlayRenderer(
              toasts: appController.toasts,
              onDismiss: appController.dismissToast,
            ),
          ],
        ),
      );
    });
  }

  // ===========================================================================
  // TOP APP BAR
  // ===========================================================================

  Widget _buildTopAppBar(BuildContext context, AppController appController) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      bottom: false,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgDark : AppColors.bgLight,
          border: Border(
            bottom: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // -----------------------------------------------------------------
            // LEFT ICON / BACK BUTTON
            // -----------------------------------------------------------------
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.corporate_fare_rounded,
                color: Colors.white,
                size: 19,
              ),
            ),
            const SizedBox(width: 10),

            // -----------------------------------------------------------------
            // TITLE
            // -----------------------------------------------------------------
            const Expanded(
              child: Text(
                'Nexus OMS',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ),

            const Spacer(),

            // -----------------------------------------------------------------
            // NOTIFICATION
            // -----------------------------------------------------------------
            Stack(
              clipBehavior: Clip.none,
              children: [
                AppIconButton(
                  icon: Icons.notifications_none_rounded,
                  size: 38,
                  onPressed: () {
                    appController.showToast(
                      'Notifications',
                      'Annual performance review submissions are now open.',
                      ToastType.info,
                    );
                  },
                ),

                Positioned(
                  right: 7,
                  top: 6,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),

            // -----------------------------------------------------------------
            // NEW LEAVE
            // -----------------------------------------------------------------
            const SizedBox(width: 6),

            Container(
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.30),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    appController.setPageIndex(1);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 11),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 4),
                        Text(
                          'New Leave',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // FLOATING IOS NAVIGATION
  // ===========================================================================

  Widget _buildFloatingNavigation(
    BuildContext context,
    AppController appController,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  height: _navigationHeight,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(
                      alpha: isDark ? 0.78 : 0.86,
                    ),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: isDark ? 0.10 : 0.08,
                      ),
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.30 : 0.12,
                        ),
                        blurRadius: 30,
                        spreadRadius: -4,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Row(
                    children: _tabs.map((tab) {
                      final isSelected =
                          appController.selectedPageIndex.value ==
                          tab.pageIndex;

                      return Expanded(
                        child: _FloatingNavItem(
                          tab: tab,
                          selected: isSelected,
                          isDark: isDark,
                          onTap: () {
                            if (isSelected) {
                              return;
                            }

                            appController.setPageIndex(tab.pageIndex);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthenticatedTaskPage extends StatelessWidget {
  final Widget body;

  const AuthenticatedTaskPage({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nexus OMS'),
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          body,
          ToastOverlayRenderer(
            toasts: appController.toasts,
            onDismiss: appController.dismissToast,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// FLOATING NAV ITEM
// =============================================================================

class _FloatingNavItem extends StatelessWidget {
  final _HomeTab tab;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _FloatingNavItem({
    required this.tab,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final activeColor = theme.colorScheme.primary;
    final inactiveColor = theme.colorScheme.onSurfaceVariant;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? activeColor.withValues(alpha: isDark ? 0.16 : 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ---------------------------------------------------------------
            // ICON
            // ---------------------------------------------------------------
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                );
              },
              child: Icon(
                selected ? tab.activeIcon : tab.icon,
                key: ValueKey('${tab.pageIndex}_$selected'),
                size: 23,
                color: selected ? activeColor : inactiveColor,
              ),
            ),

            const SizedBox(height: 3),

            // ---------------------------------------------------------------
            // LABEL
            // ---------------------------------------------------------------
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              style: TextStyle(
                fontSize: 10.5,
                height: 1,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? activeColor : inactiveColor,
                letterSpacing: -0.1,
              ),
              child: Text(
                tab.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// HOME TAB
// =============================================================================

class _HomeTab {
  final int pageIndex;
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _HomeTab({
    required this.pageIndex,
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}
