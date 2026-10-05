import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/app_data_controller.dart';
import '../controllers/leave_controller.dart';
import '../models/leave_request.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/common/app_avatar.dart';
import '../widgets/common/custom_buttons.dart';
import '../widgets/common/custom_dialogs.dart';
import '../widgets/common/custom_inputs.dart';
import '../widgets/common/custom_loading.dart';
import '../widgets/common/ui_glass_container.dart';

class LeaveHistoryScreen extends StatefulWidget {
  const LeaveHistoryScreen({super.key});

  @override
  State<LeaveHistoryScreen> createState() => _LeaveHistoryScreenState();
}

class _LeaveHistoryScreenState extends State<LeaveHistoryScreen> {
  AppDataController get _data => Get.find<AppDataController>();
  String _activeFilter = 'All';
  int _selectedYear = DateTime.now().year;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Get.find<LeaveController>().fetchLeaveHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showYearPickerSheet(List<int> availableYears, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: AppColors.softShadow(isDark),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grab handle
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black).withValues(
                    alpha: 0.2,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Year',
                    style: AppTypography.titleMedium(
                      isDark,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: availableYears.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final year = availableYears[index];
                    final isSelected = year == _selectedYear;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() => _selectedYear = year);
                          Navigator.of(ctx).pop();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(
                                    color: AppColors.primary,
                                    width: 1.5,
                                  )
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$year',
                                style: AppTypography.titleMedium(isDark)
                                    .copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? AppColors.primary
                                          : (isDark
                                                ? AppColors.textPrimaryDark
                                                : AppColors.textPrimaryLight),
                                    ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLeaveDetailDialog(LeaveRequest req, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: GlassContainer(
            borderRadius: 20,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                          Text(
                            req.employeeName,
                            style: AppTypography.titleLarge(isDark),
                          ),
                          Text(
                            'Request Reference: ${req.id}',
                            style: AppTypography.caption(isDark),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 14),
                _buildModalDetailRow(
                  'Leave Category',
                  req.leaveType.label,
                  isDark,
                ),
                _buildModalDetailRow(
                  'Start Date (From)',
                  _formatFullDate(req.startDate),
                  isDark,
                ),
                _buildModalDetailRow(
                  'End Date (To)',
                  _formatFullDate(req.endDate),
                  isDark,
                ),
                _buildModalDetailRow(
                  'Total Duration',
                  '${req.durationDays} Day(s) ${req.isHalfDay ? "(${req.halfDayType})" : ""}',
                  isDark,
                ),
                _buildModalDetailRow(
                  'Applied On Date',
                  _formatFullDate(req.appliedOn),
                  isDark,
                ),
                _buildModalDetailRow(
                  'Current Status',
                  req.status.label,
                  isDark,
                ),
                if (req.coveringEmployee != null)
                  _buildModalDetailRow(
                    'Handover Person',
                    req.coveringEmployee!,
                    isDark,
                  ),
                _buildModalDetailRow('Reason / Cause', req.reason, isDark),
                if (req.attachmentName != null)
                  _buildModalDetailRow(
                    'Attachment',
                    req.attachmentName!,
                    isDark,
                  ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (req.status == LeaveStatus.pending)
                      AppButton.outlined(
                        label: 'Cancel Request',
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          showDialog(
                            context: context,
                            builder: (c) => AppConfirmationDialog(
                              title: 'Cancel Leave Request?',
                              message:
                                  'Cancel request ${req.id} for ${req.durationDays} day(s)?',
                              confirmLabel: 'Cancel Request',
                              isDestructive: true,
                              onConfirm: () => Get.find<LeaveController>()
                                  .cancelLeaveRequest(req.id),
                            ),
                          );
                        },
                      ),
                    const SizedBox(width: 10),
                    AppButton.primary(
                      label: 'Close',
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModalDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
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

  @override
  Widget build(BuildContext context) {
    final leaveController = Get.find<LeaveController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (leaveController.isLoading.value) {
        return RefreshIndicator(
          onRefresh: leaveController.fetchLeaveHistory,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: loadingWidget(AppColors.primary),
              ),
            ],
          ),
        );
      }

      final myHistory = leaveController.leaveHistory;

      // Dynamically build list of available years from request history
      final currentYear = DateTime.now().year;
      final availableYears =
          myHistory.map((e) => e.startDate.year).toSet().toList()
            ..sort((a, b) => b.compareTo(a));

      if (!availableYears.contains(currentYear)) {
        availableYears.add(currentYear);
        availableYears.sort((a, b) => b.compareTo(a));
      }

      // Pre-calculate search filtered items for year context
      final query = _data.leaveHistorySearchQuery.trim().toLowerCase();
      final yearFiltered = myHistory.where((req) {
        final matchesYear = req.startDate.year == _selectedYear;
        final matchesSearch =
            query.isEmpty ||
            req.id.toLowerCase().contains(query) ||
            req.reason.toLowerCase().contains(query);
        return matchesYear && matchesSearch;
      }).toList();

      // Filter by active status
      final filtered = yearFiltered.where((req) {
        return switch (_activeFilter) {
          'Pending' => req.status == LeaveStatus.pending,
          'Approved' => req.status == LeaveStatus.approved,
          'Rejected' => req.status == LeaveStatus.rejected,
          _ => true,
        };
      }).toList();

      return RefreshIndicator(
        onRefresh: leaveController.fetchLeaveHistory,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row with Year Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 240,
                        child: AppSearchField(
                          controller: _searchController,
                          hint: 'Search by ID or reason...',
                          onChanged: (val) {
                            setState(() => _data.leaveHistorySearchQuery = val);
                          },
                        ),
                      ),
                      _buildProfessionalYearSelector(availableYears, isDark),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Filter Pills Row with Counts
                  _buildFilterPills(yearFiltered, isDark),

                  const SizedBox(height: 16),

                  // Leave Application Cards
                  _buildMonthSection(
                    'Leaves in $_selectedYear',
                    filtered,
                    isDark,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildProfessionalYearSelector(List<int> availableYears, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: AppColors.softShadow(isDark),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 6),
            child: Icon(
              Icons.calendar_today_rounded,
              size: 14,
              color: AppColors.primary,
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showYearPickerSheet(availableYears, isDark),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      '$_selectedYear',
                      style: AppTypography.labelLarge(isDark).copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.unfold_more_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPills(List<LeaveRequest> requests, bool isDark) {
    final allCount = requests.length;
    final pendingCount = requests
        .where((r) => r.status == LeaveStatus.pending)
        .length;
    final approvedCount = requests
        .where((r) => r.status == LeaveStatus.approved)
        .length;
    final rejectedCount = requests
        .where((r) => r.status == LeaveStatus.rejected)
        .length;

    final filters = [
      {'label': 'All', 'count': allCount, 'color': AppColors.primary},
      {
        'label': 'Pending',
        'count': pendingCount,
        'color': const Color(0xFFD97706),
      },
      {
        'label': 'Approved',
        'count': approvedCount,
        'color': const Color(0xFF059669),
      },
      {
        'label': 'Rejected',
        'count': rejectedCount,
        'color': const Color(0xFFDC2626),
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.softShadow(isDark),
        ),
        child: Row(
          children: filters.map((f) {
            final label = f['label'] as String;
            final count = f['count'] as int;
            final color = f['color'] as Color;
            final isSelected = _activeFilter == label;

            return GestureDetector(
              onTap: () => setState(() => _activeFilter = label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                            ? AppColors.cardDark
                            : AppColors.primaryContainer.withValues(alpha: 0.5))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      label,
                      style: AppTypography.labelLarge(isDark).copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? (isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight)
                            : (isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color
                            : (isDark
                                  ? color.withValues(alpha: 0.2)
                                  : color.withValues(alpha: 0.12)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMonthSection(
    String sectionHeader,
    List<LeaveRequest> requests,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            sectionHeader,
            style: AppTypography.caption(isDark).copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              fontSize: 12,
            ),
          ),
        ),

        if (requests.isEmpty)
          GlassContainer(
            borderRadius: 14,
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'No leaves matching filters for $_selectedYear.',
                style: AppTypography.bodyMedium(isDark),
              ),
            ),
          )
        else
          Column(
            children: requests
                .map((req) => _buildLeaveCard(req, isDark))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildLeaveCard(LeaveRequest req, bool isDark) {
    final durationTitle = req.isHalfDay
        ? 'Half Day Application'
        : (req.durationDays == 1.0
              ? 'Full Day Application'
              : '${req.durationDays.toInt()} Days Application');

    final dateText = req.isHalfDay || req.durationDays == 1.0
        ? _formatShortDate(req.startDate)
        : '${_formatShortDate(req.startDate)} - ${_formatShortDate(req.endDate)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.softShadow(isDark),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLeaveDetailDialog(req, isDark),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            durationTitle,
                            style: AppTypography.caption(isDark).copyWith(
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                              fontSize: 11,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: req.status.backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              req.status.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: req.status.foregroundColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateText,
                        style: AppTypography.titleMedium(
                          isDark,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        req.leaveType.label,
                        style: AppTypography.caption(isDark).copyWith(
                          color: req.leaveType.color,
                          fontWeight: FontWeight.w600,
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
                              style: AppTypography.bodyMedium(isDark).copyWith(
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
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatShortDate(DateTime dt) {
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
    return '${days[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]}';
  }

  String _formatFullDate(DateTime dt) {
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
