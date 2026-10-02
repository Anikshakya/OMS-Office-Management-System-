import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oms/models/employee.dart';
import 'package:oms/models/leave_request.dart';
import 'package:oms/widgets/common/ui_glass_container.dart';

import '../controllers/app_controller.dart';
import '../controllers/app_data_controller.dart';
import '../models/toast_notification.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/common/app_avatar.dart';
import '../widgets/common/custom_buttons.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  AppDataController get _data => Get.find<AppDataController>();
  AppController get _appController => Get.find<AppController>();
  static const int _initialPage = 1000;
  late final PageController _pageController;
  late DateTime _selectedOnLeaveDate;
  final ValueNotifier<bool> _showOnLeaveTopFade = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _selectedOnLeaveDate = DateTime.now();
    _pageController = PageController(initialPage: _initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _showOnLeaveTopFade.dispose();
    super.dispose();
  }

  DateTime _getDateForPage(int page) {
    final difference = page - _initialPage;
    return DateTime.now().add(Duration(days: difference));
  }

  int _getPageForDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    return _initialPage + target.difference(today).inDays;
  }

  void _onPageChanged(int index) {
    _showOnLeaveTopFade.value = false;
    setState(() {
      _selectedOnLeaveDate = _getDateForPage(index);
    });
  }

  void _updateOnLeaveFades(ScrollNotification notification) {
    final showTopFade = notification.metrics.pixels > 0;
    if (_showOnLeaveTopFade.value != showTopFade) {
      _showOnLeaveTopFade.value = showTopFade;
    }
  }

  void _previousDay() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
  }

  void _nextDay() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
  }

  void _resetToToday() {
    final targetPage = _getPageForDate(DateTime.now());
    _pageController.animateToPage(
      targetPage,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  void _jumpToDate(DateTime date) {
    final targetPage = _getPageForDate(date);
    _pageController.animateToPage(
      targetPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = _data.currentUser;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Banner
          _buildHeroBanner(context, isDark, user, user),

          const SizedBox(height: 20),

          // Employees On Leave Section taking all remaining screen height
          Expanded(child: _buildOnLeaveSection(isDark)),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(
    BuildContext context,
    bool isDark,
    dynamic user,
    Employee emp,
  ) {
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primary;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppColors.primaryDark.withValues(alpha: 0.4),
                  AppColors.secondary.withValues(alpha: 0.4),
                ]
              : [
                  AppColors.secondary.withValues(alpha: 0.8),
                  AppColors.secondary.withValues(alpha: 0.8),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(
              alpha: isDark ? 0.35 : 0.2,
            ),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 360;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─────────────────────────────────────────────
                // Profile Row
                // ─────────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AppAvatar(
                          url: emp.avatarUrl,
                          name: emp.name,
                          radius: isNarrow ? 24 : 28,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? AppColors.surfaceDark
                                    : Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 12),

                    // User information
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${user.name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              height: 1.2,
                            ),
                          ),

                          if (user.designation != null &&
                              user.designation.toString().isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              user.designation.toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(
                                  alpha: 0.85,
                                ),
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Department
                    if (user.department != null &&
                        user.department.toString().isNotEmpty) ...[
                      const SizedBox(width: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 130,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withValues(
                                alpha: 0.08,
                              ),
                            ),
                          ),
                          child: Text(
                            user.department
                                .toString()
                                .toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 14),

                // ─────────────────────────────────────────────
                // Dashboard / Appraisal Row
                // ─────────────────────────────────────────────
                Row(
                  children: [
                    // Dashboard icon bubble
                    const Icon(
                      Icons.dashboard_rounded,
                      color: Colors.white,
                      size: 19,
                    ),

                    const SizedBox(width: 10),

                    // Dashboard title
                    Expanded(
                      child: Text(
                        'Have a Good Day!',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleMedium(
                          isDark,
                        ).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Appraisal button
                    AppButton.secondary(
                      label: 'View Appraisal',
                      icon: Icons.star_outline_rounded,
                      onPressed: () {
                        _appController.setPageIndex(3);
                      },
                      isFullWidth: false,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      borderRadius: 10,
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryDark,
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOnLeaveSection(bool isDark) {
    final now = DateTime.now();
    final isToday =
        _selectedOnLeaveDate.year == now.year &&
        _selectedOnLeaveDate.month == now.month &&
        _selectedOnLeaveDate.day == now.day;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Navigation Controls Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Employees On Leave', style: AppTypography.titleLarge(isDark)),
            Row(
              children: [
                AppIconButton(
                  icon: Icons.chevron_left_rounded,
                  size: 28,
                  onPressed: _previousDay,
                  tooltip: 'Previous Day',
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedOnLeaveDate,
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 180),
                        ),
                        lastDate: DateTime.now().add(const Duration(days: 180)),
                      );
                      if (picked != null) {
                        _jumpToDate(picked);
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isToday
                                ? 'Today'
                                : _formatDateShort(_selectedOnLeaveDate),
                            style: AppTypography.labelLarge(isDark).copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                AppIconButton(
                  icon: Icons.chevron_right_rounded,
                  size: 28,
                  onPressed: _nextDay,
                  tooltip: 'Next Day',
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 6),

        // Full Selected Date Subtitle & Reset Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDateFull(_selectedOnLeaveDate),
              style: AppTypography.caption(isDark).copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
            if (!isToday)
              InkWell(
                onTap: _resetToToday,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.restore_rounded,
                        size: 13,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Reset to Today',
                        style: AppTypography.caption(isDark).copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 10),

        // Swipeable Container
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              final date = _getDateForPage(index);
              return _buildLeaveCardContent(date, isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLeaveCardContent(DateTime date, bool isDark) {
    final onLeaveList = _data.getEmployeesOnLeaveForDate(date);

    if (onLeaveList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 80,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.045),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06),
                ),
              ),
              child: Icon(
                Icons.event_available_rounded,
                size: 24,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.55)
                    : Colors.black.withValues(alpha: 0.45),
              ),
            ),
      
            const SizedBox(height: 14),
      
            Text(
              'No Leave Scheduled',
              textAlign: TextAlign.center,
              style: AppTypography.titleMedium(isDark).copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.1,
              ),
            ),
      
            const SizedBox(height: 5),
      
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 320,
              ),
              child: Text(
                'No employees are scheduled to be on leave on '
                '${_formatDateShort(date)}.',
                textAlign: TextAlign.center,
                style: AppTypography.caption(isDark).copyWith(
                  fontSize: 12,
                  height: 1.4,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _updateOnLeaveFades(notification);
        return false;
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          ListView.separated(
            itemCount: onLeaveList.length,
            padding: const EdgeInsets.only(bottom: 86, left: 4, right: 4),
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final req = onLeaveList[index];

              return Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppColors.softShadow(isDark),
                  border: Border.all(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showOnLeaveDetailModal(req, isDark),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          AppAvatar(
                            url: req.employeeAvatar,
                            name: req.employeeName,
                            radius: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        req.employeeName,
                                        style: AppTypography.titleMedium(
                                          isDark,
                                        ).copyWith(fontWeight: FontWeight.w700),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: req.leaveType.color.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        req.leaveType.label,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: req.leaveType.color,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  req.isHalfDay
                                      ? 'Half Day Leave (${req.halfDayType ?? ""})'
                                      : '${req.durationDays.toInt()} Day(s) Leave',
                                  style: AppTypography.caption(isDark).copyWith(
                                    color: isDark
                                        ? AppColors.textMutedDark
                                        : AppColors.textMutedLight,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.notes_rounded,
                                      size: 12,
                                      color: isDark
                                          ? AppColors.textMutedDark
                                          : AppColors.textMutedLight,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Reason: ${req.reason}',
                                        style: AppTypography.bodyMedium(isDark)
                                            .copyWith(
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _showOnLeaveTopFade,
            builder: (context, showFade, child) => showFade
                ? Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 40,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              backgroundColor,
                              backgroundColor.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 64,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      backgroundColor.withValues(alpha: 0),
                      backgroundColor,
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

  void _showOnLeaveDetailModal(LeaveRequest req, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: GlassContainer(
              borderRadius: 24,
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppAvatar(
                        url: req.employeeAvatar,
                        name: req.employeeName,
                        radius: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              req.employeeName,
                              style: AppTypography.titleLarge(
                                isDark,
                              ).copyWith(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${req.department} • On Leave Today',
                              style: AppTypography.caption(isDark).copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(),
                  const SizedBox(height: 12),
                  _buildModalDetailRow(
                    'Leave Category',
                    req.leaveType.label,
                    isDark,
                  ),
                  _buildModalDetailRow(
                    'Start Date',
                    _formatDateFull(req.startDate),
                    isDark,
                  ),
                  _buildModalDetailRow(
                    'End Date',
                    _formatDateFull(req.endDate),
                    isDark,
                  ),
                  _buildModalDetailRow(
                    'Duration',
                    '${req.durationDays} Day(s) ${req.isHalfDay ? "(${req.halfDayType ?? ""})" : ""}',
                    isDark,
                  ),
                  _buildModalDetailRow('Reason / Cause', req.reason, isDark),
                  if (req.coveringEmployee != null)
                    _buildModalDetailRow(
                      'Handover Person',
                      req.coveringEmployee!,
                      isDark,
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton.outlined(
                          label: 'Call',
                          icon: Icons.phone_rounded,
                          onPressed: () {
                            _appController.showToast(
                              'Call Employee',
                              'Dialing ${req.employeeName}...',
                              ToastType.info,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppButton.primary(
                          label: 'Email',
                          icon: Icons.email_rounded,
                          onPressed: () {
                            _appController.showToast(
                              'Compose Email',
                              'Opening mail client to email ${req.employeeName}...',
                              ToastType.info,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTypography.caption(
                isDark,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value, style: AppTypography.bodyMedium(isDark))),
        ],
      ),
    );
  }

  String _formatDateShort(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  String _formatDateFull(DateTime dt) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${days[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}
