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
      extendBody: true,
      backgroundColor: Colors.transparent,
      bottomNavigationBar: isDesktop ? null : _buildBottomNavigationBar(),
      body: SafeArea(
        bottom: false,
        child: Row(
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

    // Dark mode uses a lifted card color so the bar separates from the page
    final bgColor = isDark ? AppColors.cardDark : AppColors.surfaceLight;
    final unselectedColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.55 : 0.18),
                blurRadius: 28,
                spreadRadius: 1,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: AppColors.primary.withValues(
                  alpha: isDark ? 0.10 : 0.08,
                ),
                blurRadius: 18,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isSelected = i == selectedIndex;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () => state.setPageIndex(bottomNavPageIndices[i]),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.14)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isSelected ? item.activeIcon : item.icon,
                              size: 24,
                              color: isSelected
                                  ? AppColors.primary
                                  : unselectedColor,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.primary
                                    : unselectedColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
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
