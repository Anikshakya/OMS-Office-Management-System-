import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/app_data_controller.dart';
import '../controllers/app_controller.dart';
import '../controllers/leave_controller.dart';
import '../controllers/user_controller.dart';
import '../models/toast_notification.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/common/ui_glass_container.dart';
import '../widgets/common/custom_buttons.dart';
import '../widgets/common/custom_cupertino_date_picker.dart';
import '../widgets/common/custom_item_picker.dart';
import '../widgets/common/custom_inputs.dart';
import '../models/leave_request.dart';

/// Extension to map colors directly to the LeaveType enum
extension LeaveTypeColorX on LeaveType {
  Color get color {
    switch (this) {
      case LeaveType.annual:
        return AppColors.primary;
      case LeaveType.sick:
        return AppColors.secondary;
      case LeaveType.casual:
        return AppColors.warning;
      case LeaveType.maternityPaternity:
        return const Color(0xFF8B5CF6);
      case LeaveType.unpaid:
        return Colors.grey;
    }
  }
}

class ApplyLeaveScreen extends StatefulWidget {
  const ApplyLeaveScreen({super.key});

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  static const List<String> _durationOptions = [
    'Full Day',
    '1st Half',
    '2nd Half',
    '1st Quarter',
    '2nd Quarter',
    '3rd Quarter',
    '4th Quarter',
  ];

  AppDataController get _data => Get.find<AppDataController>();
  AppController get _appController => Get.find<AppController>();
  UserController get _userController => Get.find<UserController>();
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _categoryPickerKey = GlobalKey();

  LeaveType _selectedType = LeaveType.casual;
  DateTime _startDate = DateTime.now().add(const Duration(days: 2));
  DateTime _endDate = DateTime.now().add(const Duration(days: 4));

  // Duration Type: 'full', 'half', 'quarter'
  String _durationType = 'full';
  String _halfDayPeriod = 'AM';
  String _quarterPeriod = 'Q1 (Morning)';

  String get _selectedDurationOption {
    if (_durationType == 'half') {
      return _halfDayPeriod == 'AM' ? '1st Half' : '2nd Half';
    }
    if (_durationType == 'quarter') {
      switch (_quarterPeriod) {
        case 'Q1 (Morning)':
          return '1st Quarter';
        case 'Q2 (Midday)':
          return '2nd Quarter';
        case 'Q3 (Afternoon)':
          return '3rd Quarter';
        case 'Q4 (Evening)':
          return '4th Quarter';
      }
    }
    return 'Full Day';
  }

  final TextEditingController _reasonController = TextEditingController(
    text: 'Personal leave and medical checkup',
  );
  final TextEditingController _emergencyContactController =
      TextEditingController(text: '+1 (555) 234-5678');
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _userController.fetchEmployeeProfile();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _reasonController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  double get _calculatedDays {
    if (_durationType == 'half') return 0.5;
    if (_durationType == 'quarter') return 0.25;
    final diff = _endDate.difference(_startDate).inDays + 1;
    return diff < 1 ? 1.0 : diff.toDouble();
  }

  String get _durationLabel {
    if (_durationType == 'half') return '0.5 Day (Half Day - $_halfDayPeriod)';
    if (_durationType == 'quarter') {
      return '0.25 Day (Quarter Day - $_quarterPeriod)';
    }
    final days = _calculatedDays.toInt();
    return '$days Day${days > 1 ? "s" : ""} (Full Day)';
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart ? _startDate : _endDate;
    final now = DateTime.now();
    final dateController = TextEditingController(
      text: initialDate.toIso8601String().split('T').first,
    );
    final DateTime? picked;
    try {
      picked = await showCustomCupertinoDatePicker(
        showTime: true,
        context: context,
        controller: dateController,
        minDate: now.subtract(const Duration(days: 30)),
        maxDate: now.add(const Duration(days: 365)),
      );
    } finally {
      dateController.dispose();
    }

    final selectedDate = picked;
    if (selectedDate != null) {
      setState(() {
        if (_durationType != 'full') {
          _startDate = selectedDate;
          _endDate = selectedDate;
          return;
        }

        if (isStart) {
          _startDate = selectedDate;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = selectedDate;
          if (_endDate.isBefore(_startDate)) {
            _startDate = _endDate;
          }
        }
      });
    }
  }

  Future<void> _selectDuration() async {
    final selectedOption = await showCustomCupertinoItemPicker<String>(
      context: context,
      items: _durationOptions,
      initialItem: _selectedDurationOption,
      itemLabelBuilder: (item) => item,
      title: 'Select Leave Duration',
    );
    if (selectedOption == null || !mounted) return;

    setState(() {
      if (selectedOption == 'Full Day') {
        _durationType = 'full';
      } else if (selectedOption == '1st Half') {
        _durationType = 'half';
        _halfDayPeriod = 'AM';
      } else if (selectedOption == '2nd Half') {
        _durationType = 'half';
        _halfDayPeriod = 'PM';
      } else if (selectedOption == '1st Quarter') {
        _durationType = 'quarter';
        _quarterPeriod = 'Q1 (Morning)';
      } else if (selectedOption == '2nd Quarter') {
        _durationType = 'quarter';
        _quarterPeriod = 'Q2 (Midday)';
      } else if (selectedOption == '3rd Quarter') {
        _durationType = 'quarter';
        _quarterPeriod = 'Q3 (Afternoon)';
      } else {
        _durationType = 'quarter';
        _quarterPeriod = 'Q4 (Evening)';
      }

      if (_durationType != 'full') {
        _endDate = _startDate;
      }
    });
  }

  String _formatDate(DateTime dt) {
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

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      _appController.showToast(
        'Validation Error',
        'Please enter a valid reason for your leave.',
        ToastType.error,
      );
      return;
    }

    final user = _userController.currentUser.value;
    final employeeId = int.tryParse(
      (_userController.employeeProfileData['employee_id'] ?? user?.id ?? '')
          .toString(),
    );
    if (employeeId == null) {
      _appController.showToast(
        'Submission Error',
        'Unable to identify your employee account. Please try again.',
        ToastType.error,
      );
      return;
    }

    final supervisorId =
        (_userController.employeeProfileData['supervisor_id'] ??
                _userController.employeeProfileData['supervisor_ids'] ??
                '')
            .toString()
            .trim();
    if (int.tryParse(supervisorId) == null) {
      _appController.showToast(
        'Submission Error',
        'Unable to identify your assigned supervisor. Please reload your profile and try again.',
        ToastType.error,
      );
      return;
    }

    final leaveId = switch (_selectedType) {
      LeaveType.annual => 1,
      LeaveType.sick => 2,
      LeaveType.casual => 3,
      LeaveType.maternityPaternity => 4,
      LeaveType.unpaid => null,
    };
    if (leaveId == null) {
      _appController.showToast(
        'Submission Error',
        'Unpaid leave requests are not supported yet.',
        ToastType.error,
      );
      return;
    }

    final leaveDurationType = switch (_durationType) {
      'full' => '1',
      'half' => '2',
      'quarter' => '3',
      _ => null,
    };
    if (leaveDurationType == null) {
      _appController.showToast(
        'Submission Error',
        'Please select a valid leave duration.',
        ToastType.error,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final submitted = await Get.find<LeaveController>().applyLeave(
        supervisorId: supervisorId,
        coveringEmployee: '',
        startDate: _startDate,
        endDate: _durationType == 'full' ? _endDate : _startDate,
        leaveId: leaveId,
        leaveDurationType: leaveDurationType,
        leaveReason: reason,
        employeeId: employeeId,
      );
      if (submitted) {
        _appController.setPageIndex(4);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Fetch metrics for selected leave type
    final selectedBalance = _data.currentUser.leaveBalances[_selectedType];
    final usedDays = selectedBalance?.used ?? 0;
    final remainingDays = selectedBalance?.remaining ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Apply Leave'), centerTitle: true),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Banner displaying selected category stats
                  GlassContainer(
                    borderRadius: 16,
                    padding: const EdgeInsets.all(16),
                    child: Builder(
                      builder: (context) {
                        // Fetch color directly from the enum
                        final leaveTypeColor = _selectedType.color;

                        final double totalAllocated = (usedDays + remainingDays)
                            .toDouble();
                        final double progress = totalAllocated > 0
                            ? (usedDays / totalAllocated).clamp(0.0, 1.0)
                            : 0.0;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Header: Leave Name + Remaining Badge
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${_selectedType.label} Leave',
                                    style: AppTypography.titleLarge(isDark)
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -0.3,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: leaveTypeColor.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: leaveTypeColor.withValues(
                                        alpha: 0.25,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '$remainingDays ${remainingDays == 1 ? 'day' : 'days'} left',
                                    style: AppTypography.labelMedium(isDark)
                                        .copyWith(
                                          color: leaveTypeColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Graphical Linear Progress Bar matching LeaveType Color
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.06),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  leaveTypeColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Sub-metrics: Used vs Total Quota
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Used: $usedDays ${usedDays == 1 ? 'day' : 'days'}',
                                  style: AppTypography.bodyMedium(isDark)
                                      .copyWith(
                                        color: isDark
                                            ? Colors.white60
                                            : Colors.black54,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                Text(
                                  'Total: ${totalAllocated.toInt()} ${totalAllocated == 1 ? 'day' : 'days'}',
                                  style: AppTypography.bodyMedium(isDark)
                                      .copyWith(
                                        color: isDark
                                            ? Colors.white60
                                            : Colors.black54,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 1. Leave Category Selection
                  _buildSectionLabel('1. Leave Category', isDark),
                  const SizedBox(height: 8),
                  _buildCategoryPicker(isDark),

                  const SizedBox(height: 16),

                  // 2. Date Range & Duration Card
                  _buildSectionLabel('2. Date Range & Duration Type', isDark),
                  const SizedBox(height: 8),
                  _buildDateCard(isDark),

                  const SizedBox(height: 16),

                  // 3. Assigned Supervisor
                  _buildSectionLabel('3. Assigned Supervisor', isDark),
                  const SizedBox(height: 8),
                  _buildSupervisorAndHandoverCard(isDark),

                  const SizedBox(height: 16),

                  // 4. Reason / Cause Card
                  _buildSectionLabel('4. Reason for Absence', isDark),
                  const SizedBox(height: 8),
                  GlassContainer(
                    borderRadius: 16,
                    padding: const EdgeInsets.all(16),
                    child: AppTextField(
                      controller: _reasonController,
                      label: 'Leave Reason / Justification',
                      hint: 'Describe why you are requesting leave...',
                      maxLines: 3,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Submit Button
                  AppButton.primary(
                    label: _isSubmitting
                        ? 'Submitting Request...'
                        : 'Submit ${_durationLabel.split("(").first.trim()} Leave Request',
                    isFullWidth: true,
                    isLoading: _isSubmitting,
                    icon: Icons.send_rounded,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    borderRadius: 16,
                    onPressed: _handleSubmit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String title, bool isDark) {
    return Text(
      title,
      style: AppTypography.titleMedium(
        isDark,
      ).copyWith(fontWeight: FontWeight.w700),
    );
  }

  Future<void> _selectLeaveCategory() async {
    final selectedType = await showCustomCupertinoItemPicker<LeaveType>(
      context: context,
      items: LeaveType.values,
      initialItem: _selectedType,
      itemLabelBuilder: (type) => type.label,
      title: 'Select Leave Category',
    );
    if (selectedType == null || !mounted) return;

    final pickerContext = _categoryPickerKey.currentContext;
    final pickerRenderObject = pickerContext?.findRenderObject();
    final previousPickerTop = pickerRenderObject is RenderBox
        ? pickerRenderObject.localToGlobal(Offset.zero).dy
        : null;

    setState(() => _selectedType = selectedType);
    if (previousPickerTop != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scrollController.hasClients) return;
        final updatedContext = _categoryPickerKey.currentContext;
        final updatedRenderObject = updatedContext?.findRenderObject();
        if (updatedRenderObject is! RenderBox) return;

        final updatedPickerTop = updatedRenderObject
            .localToGlobal(Offset.zero)
            .dy;
        final scrollDelta = updatedPickerTop - previousPickerTop;
        if (scrollDelta == 0) return;

        final position = _scrollController.position;
        _scrollController.jumpTo(
          (position.pixels + scrollDelta)
              .clamp(0.0, position.maxScrollExtent)
              .toDouble(),
        );
      });
    }
  }

  Widget _buildCategoryPicker(bool isDark) {
    final categoryColor = _selectedType.color;

    return InkWell(
      key: _categoryPickerKey,
      onTap: _selectLeaveCategory,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: isDark ? null : Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Icon(Icons.circle, size: 10, color: categoryColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _selectedType.label,
                style: AppTypography.bodyMedium(
                  isDark,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const Icon(
              Icons.unfold_more_rounded,
              size: 20,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateCard(bool isDark) {
    return GlassContainer(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Leave duration selector
          Text(
            'Duration',
            style: AppTypography.caption(
              isDark,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _selectDuration,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.bgLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDurationOption,
                      style: AppTypography.bodyMedium(
                        isDark,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Icon(
                    Icons.unfold_more_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context, true),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.bgLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Date (From)',
                          style: AppTypography.caption(isDark),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _formatDate(_startDate),
                                style: AppTypography.bodyMedium(
                                  isDark,
                                ).copyWith(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_durationType == 'full') ...[
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, false),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : AppColors.bgLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'End Date (To)',
                            style: AppTypography.caption(isDark),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_month_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _formatDate(_endDate),
                                  style: AppTypography.bodyMedium(
                                    isDark,
                                  ).copyWith(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Calculated Leave Duration:',
                  style: AppTypography.caption(
                    isDark,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                Flexible(
                  child: Text(
                    _durationLabel,
                    style: AppTypography.bodyMedium(isDark).copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupervisorAndHandoverCard(bool isDark) {
    return GlassContainer(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Obx(() {
        final isLoading = _userController.isEmployeeProfileLoading.value;
        final error = _userController.employeeProfileError.value;
        final supervisor =
            _userController.employeeProfileData['supervisor_ids_text']
                ?.toString()
                .trim() ??
            '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InputDecorator(
              decoration: InputDecoration(
                labelText: 'Assigned Supervisor / Approver',
                labelStyle: AppTypography.caption(
                  isDark,
                ).copyWith(fontWeight: FontWeight.bold),
                prefixIcon: const Icon(
                  Icons.supervisor_account_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isLoading
                          ? 'Loading assigned supervisor...'
                          : supervisor.isNotEmpty
                          ? supervisor
                          : error.isNotEmpty
                          ? 'Unable to load supervisor'
                          : 'Not assigned',
                      style: AppTypography.bodyMedium(isDark),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isLoading)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (error.isNotEmpty)
                    IconButton(
                      tooltip: 'Retry',
                      onPressed: _userController.fetchEmployeeProfile,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _emergencyContactController,
              label: 'Emergency Contact Phone',
              hint: 'Phone number while on leave...',
              prefixIcon: Icons.phone_outlined,
            ),
          ],
        );
      }),
    );
  }
}
