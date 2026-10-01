import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/common/ui_glass_container.dart';
import '../widgets/common/custom_buttons.dart';
import '../widgets/common/custom_selectors.dart';
import '../widgets/common/custom_states.dart';
import '../widgets/common/app_avatar.dart';

class EmployeesOnLeaveTodayScreen extends StatefulWidget {
  final AppState state;

  const EmployeesOnLeaveTodayScreen({super.key, required this.state});

  @override
  State<EmployeesOnLeaveTodayScreen> createState() => _EmployeesOnLeaveTodayScreenState();
}

class _EmployeesOnLeaveTodayScreenState extends State<EmployeesOnLeaveTodayScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedDept = 'All';

  void _previousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
  }

  void _nextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
  }

  void _today() {
    setState(() {
      _selectedDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.state.isDarkMode;
    final onLeaveForDate = widget.state.getEmployeesOnLeaveForDate(_selectedDate);

    final filtered = onLeaveForDate.where((req) {
      return _selectedDept == 'All' || req.department == _selectedDept;
    }).toList();

    final isToday = _selectedDate.year == DateTime.now().year &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.day == DateTime.now().day;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Control Header Card (With Swipe / Date Filter!)
              GlassContainer(
                borderRadius: 16,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppIconButton(
                          icon: Icons.chevron_left_rounded,
                          onPressed: _previousDay,
                          tooltip: 'Previous Day',
                        ),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime.now().subtract(const Duration(days: 180)),
                              lastDate: DateTime.now().add(const Duration(days: 180)),
                            );
                            if (picked != null) {
                              setState(() => _selectedDate = picked);
                            }
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  isToday ? 'Today (${_formatDate(_selectedDate)})' : _formatDate(_selectedDate),
                                  style: AppTypography.titleLarge(isDark).copyWith(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                        AppIconButton(
                          icon: Icons.chevron_right_rounded,
                          onPressed: _nextDay,
                          tooltip: 'Next Day',
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (!isToday)
                      AppButton.text(
                        label: 'Jump to Today',
                        onPressed: _today,
                      ),

                    const SizedBox(height: 12),

                    AppChipSelect<String>(
                      options: const ['All', 'Engineering', 'Product & Design', 'Human Resources', 'Marketing'],
                      selectedValue: _selectedDept,
                      labelBuilder: (d) => d,
                      onSelected: (val) => setState(() => _selectedDept = val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Horizontal Swipe Listener Wrapper
              GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity != null) {
                    if (details.primaryVelocity! < 0) {
                      _nextDay(); // Swipe left -> Next day
                    } else if (details.primaryVelocity! > 0) {
                      _previousDay(); // Swipe right -> Previous day
                    }
                  }
                },
                child: filtered.isEmpty
                    ? GlassContainer(
                        borderRadius: 16,
                        child: AppEmptyState(
                          icon: Icons.task_alt_rounded,
                          title: 'No Personnel Away',
                          message: 'No employees are on leave on ${_formatDate(_selectedDate)}.',
                        ),
                      )
                    : Column(
                        children: filtered.map((req) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: GlassContainer(
                              borderRadius: 16,
                              padding: const EdgeInsets.all(16),
                              child: Column(
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
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(req.employeeName, style: AppTypography.titleMedium(isDark), overflow: TextOverflow.ellipsis),
                                                ),
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primary.withValues(alpha: 0.12),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    req.leaveType.label,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              '${req.department} • ${_formatDate(req.startDate)} to ${_formatDate(req.endDate)}',
                                              style: AppTypography.caption(isDark),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.handshake_outlined, color: AppColors.secondary, size: 16),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            'Handover: ${req.coveringEmployee ?? "Team Lead"}',
                                            style: AppTypography.labelLarge(isDark).copyWith(fontSize: 11),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  // Always display leave reason
                                  Text(
                                    'Reason: "${req.reason}"',
                                    style: AppTypography.bodyMedium(isDark).copyWith(fontStyle: FontStyle.italic, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${days[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}
