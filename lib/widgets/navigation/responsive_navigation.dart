import 'dart:io';
import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../common/custom_buttons.dart';

class NavItem {
  final int index;
  final String title;
  final IconData icon;
  final IconData activeIcon;

  const NavItem({
    required this.index,
    required this.title,
    required this.icon,
    required this.activeIcon,
  });
}

const List<NavItem> kNavigationItems = [
  NavItem(
    index: 0,
    title: 'Dashboard',
    icon: Icons.explore_outlined,
    activeIcon: Icons.explore_rounded,
  ),
  NavItem(
    index: 1,
    title: 'New Leave',
    icon: Icons.add_circle_outline_rounded,
    activeIcon: Icons.add_circle_rounded,
  ),
  NavItem(
    index: 2,
    title: 'Profile',
    icon: Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
  ),
  NavItem(
    index: 3,
    title: 'Appraisal',
    icon: Icons.assessment_outlined,
    activeIcon: Icons.assessment_rounded,
  ),
  NavItem(
    index: 4,
    title: 'Leaves',
    icon: Icons.history_rounded,
    activeIcon: Icons.history_edu_rounded,
  ),
  NavItem(
    index: 5,
    title: 'Employees',
    icon: Icons.people_outline_rounded,
    activeIcon: Icons.people_rounded,
  ),
  NavItem(
    index: 6,
    title: 'Away Today',
    icon: Icons.event_available_outlined,
    activeIcon: Icons.event_available_rounded,
  ),
];

class ResponsiveNavigationShell extends StatelessWidget {
  final AppState state;
  final Widget body;

  const ResponsiveNavigationShell({
    super.key,
    required this.state,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 950;

    return Scaffold(
      bottomNavigationBar: isDesktop ? null : _buildBottomNavigationBar(),
      body: SafeArea(
        bottom: Platform.isIOS ? false : true,
        child: Stack(
          children: [
            // Full height content container scrolling behind floating bar
            Row(
              children: [
                if (isDesktop) _buildSidebar(context),
                Expanded(
                  child: Column(
                    children: [
                      _buildTopAppBar(context, isDesktop: isDesktop),
                      Expanded(child: ClipRect(child: body)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar(BuildContext context, {required bool isDesktop}) {
    final isDark = state.isDarkMode;
    final currentNav = kNavigationItems.firstWhere(
      (item) => item.index == state.selectedPageIndex,
      orElse: () => kNavigationItems[0],
    );

    // Apply Leave (index 1) and Appraisal (index 3) are separate sub-pages with back buttons!
    final isSubPage =
        state.selectedPageIndex == 1 || state.selectedPageIndex == 3;

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
          if (isSubPage) ...[
            AppIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              size: 36,
              onPressed: () => state.setPageIndex(0),
              tooltip: 'Back to Dashboard',
            ),
            const SizedBox(width: 12),
          ] else if (!isDesktop) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.corporate_fare_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
          ],

          Text(
            currentNav.title,
            style: AppTypography.displayLarge(
              isDark,
            ).copyWith(fontSize: 20, fontWeight: FontWeight.w800),
          ),

          const Spacer(),

          // Notification icon
          Stack(
            children: [
              AppIconButton(
                icon: Icons.notifications_none_rounded,
                size: 38,
                onPressed: () {
                  state.showToast(
                    'Notifications',
                    'Annual performance review submissions are now open.',
                    ToastType.info,
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
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

          const SizedBox(width: 10),

          // Apply Leave quick action button in header
          Container(
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => state.setPageIndex(1),
                borderRadius: BorderRadius.circular(10),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
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
    );
  }

  Widget _buildBottomNavigationBar() {
    final isDark = state.isDarkMode;
    const bottomNavPageIndices = [0, 4, 5, 2];
    final selectedIndex = bottomNavPageIndices.indexOf(state.selectedPageIndex);
    final items = bottomNavPageIndices
        .map((index) => kNavigationItems[index])
        .toList();

    final bgColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.4 : 0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BottomNavigationBar(
              currentIndex: selectedIndex < 0 ? 0 : selectedIndex,
              onTap: (index) => state.setPageIndex(bottomNavPageIndices[index]),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
              items: items
                  .map(
                    (item) => BottomNavigationBarItem(
                      icon: Icon(item.icon),
                      activeIcon: Icon(item.activeIcon),
                      label: item.title,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final isDark = state.isDarkMode;

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          right: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.corporate_fare_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'NEXUS OMS',
                    style: AppTypography.titleMedium(
                      isDark,
                    ).copyWith(fontWeight: FontWeight.w800),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: kNavigationItems.length,
              separatorBuilder: (_, index) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final item = kNavigationItems[index];
                final isSelected = state.selectedPageIndex == item.index;

                return InkWell(
                  onTap: () => state.setPageIndex(item.index),
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                                ? AppColors.cardDark
                                : AppColors.primaryContainer)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          size: 20,
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.title,
                            style: AppTypography.labelLarge(isDark).copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? (isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.primary)
                                  : (isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Dark Mode', style: AppTypography.labelMedium(isDark)),
                Switch.adaptive(
                  value: isDark,
                  activeTrackColor: AppColors.primary,
                  onChanged: (_) => state.toggleTheme(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
