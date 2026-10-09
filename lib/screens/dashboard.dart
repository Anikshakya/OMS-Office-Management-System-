// =============================================================================
// AUTHENTICATED HOME
// =============================================================================
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oms/controllers/app_controller.dart';
import 'package:oms/controllers/user_controller.dart';
import 'package:oms/models/toast_notification.dart';
import 'package:oms/screens/dashboard_screen.dart';
import 'package:oms/screens/employee_list_screen.dart';
import 'package:oms/screens/employee_profile_screen.dart';
import 'package:oms/screens/employees_on_leave_today_screen.dart';
import 'package:oms/screens/leave_history_screen.dart';
import 'package:oms/theme/app_colors.dart';
import 'package:oms/widgets/common/custom_buttons.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // ---------------------------------------------------------------------------
  // Navigation Tabs Configuration
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
        extendBody:
            true, // Allows body content to show behind translucent blurred floating nav
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
        body: _pages[stackIndex],

        // ---------------------------------------------------------------------
        // FLOATING IOS GLASS NAVIGATION BAR
        // ---------------------------------------------------------------------
        bottomNavigationBar: _buildIosFloatingNav(context, appController),
      );
    });
  }

  // ===========================================================================
  // FLOATING IOS NAVIGATION BAR
  // ===========================================================================

  Widget _buildIosFloatingNav(
    BuildContext context,
    AppController appController,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  height: 66,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: (isDark ? const Color(0xFF1E1E1E) : Colors.white)
                        .withValues(alpha: isDark ? 0.72 : 0.82),
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.black.withValues(alpha: 0.08),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.45 : 0.14,
                        ),
                        blurRadius: 28,
                        spreadRadius: -2,
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
                            if (!isSelected) {
                              appController.setPageIndex(tab.pageIndex);
                            }
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

  // ===========================================================================
  // TOP APP BAR
  // ===========================================================================

  Widget _buildTopAppBar(BuildContext context, AppController appController) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isProfilePage = appController.selectedPageIndex.value == 2;

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
            if (isProfilePage) ...[
              SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  tooltip: 'Back',
                  onPressed: () => appController.setPageIndex(0),
                  padding: EdgeInsets.zero,
                  style: IconButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColors.cardDark
                        : const Color(0xFFE4E9F2),
                    foregroundColor: isDark
                        ? Colors.white
                        : AppColors.textPrimaryLight,
                  ),
                  icon: const Icon(Icons.chevron_left_rounded, size: 22),
                ),
              ),
              Expanded(
                child: Text(
                  Get.find<UserController>()
                              .employeeProfileData['employee_name']
                              ?.toString()
                              .trim()
                              .isNotEmpty ==
                          true
                      ? Get.find<UserController>()
                            .employeeProfileData['employee_name']
                            .toString()
                      : Get.find<UserController>().currentUser.value?.name ??
                            'Employee',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ] else ...[
              // -----------------------------------------------------------------
              // LEFT ICON / LOGO
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
                  ' OMS',
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
            ],
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// FLOATING NAV ITEM
// =============================================================================

class _FloatingNavItem extends StatefulWidget {
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
  State<_FloatingNavItem> createState() => _FloatingNavItemState();
}

class _FloatingNavItemState extends State<_FloatingNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _yOffsetAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // Controller for the iOS spring bounce effect
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Spring scale effect (1.0 -> 1.25 -> 1.0)
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.28,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.28,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 65,
      ),
    ]).animate(_bounceController);

    // Subtle upward jump during the bounce (-4px lift)
    _yOffsetAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: -4.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -4.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 65,
      ),
    ]).animate(_bounceController);

    // Trigger bounce on initial load if pre-selected
    if (widget.selected) {
      _bounceController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant _FloatingNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger the bounce sequence whenever this tab becomes selected
    if (widget.selected && !oldWidget.selected) {
      _bounceController.reset();
      _bounceController.forward();
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = widget.isDark
        ? Colors.white.withValues(alpha: 0.55)
        : Colors.black.withValues(alpha: 0.45);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        Feedback.forTap(context);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.decelerate,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: widget.selected
                ? activeColor.withValues(alpha: widget.isDark ? 0.18 : 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Bouncing Icon with scale & translation vertical lift
              AnimatedBuilder(
                animation: _bounceController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _yOffsetAnimation.value),
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: Icon(
                  widget.selected ? widget.tab.activeIcon : widget.tab.icon,
                  key: ValueKey('${widget.tab.pageIndex}_${widget.selected}'),
                  size: 22,
                  color: widget.selected ? activeColor : inactiveColor,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: widget.selected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: widget.selected ? activeColor : inactiveColor,
                  letterSpacing: -0.1,
                ),
                child: Text(
                  widget.tab.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// HOME TAB MODEL
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
