import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/common/ui_glass_container.dart';
import '../widgets/common/custom_buttons.dart';
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
  final AppState state;

  const ApplyLeaveScreen({super.key, required this.state});

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  final _formKey = GlobalKey<FormState>();

  LeaveType _selectedType = LeaveType.casual;
  DateTime _startDate = DateTime.now().add(const Duration(days: 2));
  DateTime _endDate = DateTime.now().add(const Duration(days: 4));

  // Duration Type: 'full', 'half', 'quarter'
  String _durationType = 'full';
  String _halfDayPeriod = 'AM';
  String _quarterPeriod = 'Q1 (Morning)';

  // Auto-selected supervisor + supervisor selection dropdown
  late String _selectedSupervisor;
  String? _coveringEmployee;

  final TextEditingController _reasonController =
      TextEditingController(text: 'Personal leave and medical checkup');
  final TextEditingController _emergencyContactController =
      TextEditingController(text: '+1 (555) 234-5678');
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Auto-select reporting manager
    _selectedSupervisor = widget.state.currentUser.managerName;
    if (widget.state.employees.isNotEmpty) {
      _coveringEmployee = widget.state.employees.first.name;
    }
  }

  @override
  void dispose() {
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
    if (_durationType == 'quarter') return '0.25 Day (Quarter Day - $_quarterPeriod)';
    final days = _calculatedDays.toInt();
    return '$days Day${days > 1 ? "s" : ""} (Full Day)';
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _startDate = _endDate;
          }
        }
      });
    }
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

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      widget.state.showToast(
        'Validation Error',
        'Please enter a valid reason for your leave.',
        ToastType.error,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 600));

    final isHalfOrQuarter = _durationType != 'full';
    final periodText = _durationType == 'half'
        ? _halfDayPeriod
        : (_durationType == 'quarter' ? _quarterPeriod : null);

    widget.state.submitLeaveRequest(
      leaveType: _selectedType,
      startDate: _startDate,
      endDate: _endDate,
      durationDays: _calculatedDays,
      isHalfDay: isHalfOrQuarter,
      halfDayType: periodText,
      reason: reason,
      coveringEmployee: _coveringEmployee,
    );

    setState(() => _isSubmitting = false);
    widget.state.setPageIndex(4); // Navigate to Leaves list
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.state.isDarkMode;

    // Fetch metrics for selected leave type
    final selectedBalance = widget.state.currentUser.leaveBalances[_selectedType];
    final usedDays = selectedBalance?.used ?? 0;
    final remainingDays = selectedBalance?.remaining ?? 0;

    return SingleChildScrollView(
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

                      final double totalAllocated = (usedDays + remainingDays).toDouble();
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
                                  style: AppTypography.titleLarge(isDark).copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: leaveTypeColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: leaveTypeColor.withValues(alpha: 0.25),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '$remainingDays ${remainingDays == 1 ? 'day' : 'days'} left',
                                  style: AppTypography.labelMedium(isDark).copyWith(
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
                              valueColor: AlwaysStoppedAnimation<Color>(leaveTypeColor),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Sub-metrics: Used vs Total Quota
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Used: $usedDays ${usedDays == 1 ? 'day' : 'days'}',
                                style: AppTypography.bodyMedium(isDark).copyWith(
                                  color: isDark ? Colors.white60 : Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Total: ${totalAllocated.toInt()} ${totalAllocated == 1 ? 'day' : 'days'}',
                                style: AppTypography.bodyMedium(isDark).copyWith(
                                  color: isDark ? Colors.white60 : Colors.black54,
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
                _buildCategoryChips(isDark),

                const SizedBox(height: 16),

                // 2. Date Range & Duration Card
                _buildSectionLabel('2. Date Range & Duration Type', isDark),
                const SizedBox(height: 8),
                _buildDateCard(isDark),

                const SizedBox(height: 16),

                // 3. Supervisor & Handover Card
                _buildSectionLabel('3. Supervisor & Handover Details', isDark),
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

  Widget _buildCategoryChips(bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: LeaveType.values.map((type) {
        final isSelected = _selectedType == type;
        final color = type.color;

        return GestureDetector(
          onTap: () => setState(() => _selectedType = type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? color
                  : (isDark ? AppColors.surfaceDark : Colors.white),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? color
                    : (isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight),
                width: 1.5,
              ),
              boxShadow: isSelected ? AppColors.softShadow(isDark) : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  size: 8,
                  color: isSelected ? Colors.white : color,
                ),
                const SizedBox(width: 8),
                Text(
                  type.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateCard(bool isDark) {
    return GlassContainer(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        Text('Start Date (From)', style: AppTypography.caption(isDark)),
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
                                style: AppTypography.bodyMedium(isDark).copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
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
                        Text('End Date (To)', style: AppTypography.caption(isDark)),
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
                                style: AppTypography.bodyMedium(isDark).copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
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
          ),

          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 10),

          // Responsive Duration Selector (Full, Half, Quarter)
          Text(
            'Duration Type',
            style: AppTypography.caption(isDark).copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Full Day (1.0)'),
                selected: _durationType == 'full',
                onSelected: (_) => setState(() => _durationType = 'full'),
              ),
              ChoiceChip(
                label: const Text('Half Day (0.5)'),
                selected: _durationType == 'half',
                onSelected: (_) => setState(() => _durationType = 'half'),
              ),
              ChoiceChip(
                label: const Text('Quarter Day (0.25)'),
                selected: _durationType == 'quarter',
                onSelected: (_) => setState(() => _durationType = 'quarter'),
              ),
            ],
          ),

          if (_durationType == 'half') ...[
            const SizedBox(height: 10),
            Text(
              'Select Half Day Period',
              style: AppTypography.caption(isDark).copyWith(fontSize: 11),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ChoiceChip(
                  label: const Text('AM (Morning Session)'),
                  selected: _halfDayPeriod == 'AM',
                  onSelected: (_) => setState(() => _halfDayPeriod = 'AM'),
                ),
                ChoiceChip(
                  label: const Text('PM (Afternoon Session)'),
                  selected: _halfDayPeriod == 'PM',
                  onSelected: (_) => setState(() => _halfDayPeriod = 'PM'),
                ),
              ],
            ),
          ],

          if (_durationType == 'quarter') ...[
            const SizedBox(height: 10),
            Text(
              'Select Quarter Period',
              style: AppTypography.caption(isDark).copyWith(fontSize: 11),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                'Q1 (Morning)',
                'Q2 (Midday)',
                'Q3 (Afternoon)',
                'Q4 (Evening)',
              ].map((q) {
                return ChoiceChip(
                  label: Text(q),
                  selected: _quarterPeriod == q,
                  onSelected: (_) => setState(() => _quarterPeriod = q),
                );
              }).toList(),
            ),
          ],

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
                  style: AppTypography.caption(isDark).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
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
    // List of supervisors/managers available for selection
    final supervisors = <String>{
      widget.state.currentUser.managerName,
      'Sarah Jenkins (VP Design)',
      'Marcus Vance (VP Engineering)',
      'Elena Rostova (Lead HR)',
      'David Miller (Director of Product)',
    }.toList();

    return GlassContainer(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Auto-Selected Supervisor Dropdown
          DropdownButtonFormField<String>(
            initialValue: _selectedSupervisor,
            decoration: InputDecoration(
              labelText: 'Assigned Supervisor / Approver (Auto-Selected)',
              labelStyle: AppTypography.caption(isDark).copyWith(
                fontWeight: FontWeight.bold,
              ),
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
            items: supervisors.map((sup) {
              return DropdownMenuItem(
                value: sup,
                child: Text(
                  sup,
                  style: AppTypography.bodyMedium(isDark),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedSupervisor = val);
            },
          ),

          const SizedBox(height: 14),

          // Handover Colleague Dropdown
          DropdownButtonFormField<String>(
            initialValue: _coveringEmployee,
            decoration: InputDecoration(
              labelText: 'Handover / Covering Colleague',
              labelStyle: AppTypography.caption(isDark),
              prefixIcon: const Icon(
                Icons.people_outline_rounded,
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
            items: widget.state.employees.map((emp) {
              return DropdownMenuItem(
                value: emp.name,
                child: Text(
                  '${emp.name} (${emp.department})',
                  style: AppTypography.bodyMedium(isDark),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _coveringEmployee = val);
            },
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _emergencyContactController,
            label: 'Emergency Contact Phone',
            hint: 'Phone number while on leave...',
            prefixIcon: Icons.phone_outlined,
          ),
        ],
      ),
    );
  }
}