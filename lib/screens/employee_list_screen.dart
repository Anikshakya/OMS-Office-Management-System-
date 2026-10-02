import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/app_data_controller.dart';
import '../controllers/app_controller.dart';
import '../models/toast_notification.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/common/ui_glass_container.dart';
import '../widgets/common/custom_buttons.dart';
import '../widgets/common/custom_inputs.dart';
import '../widgets/common/app_avatar.dart';
import '../models/employee.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  AppDataController get _data => Get.find<AppDataController>();
  AppController get _appController => Get.find<AppController>();
  final TextEditingController _searchController = TextEditingController();

  final List<String> _departments = const [
    'All',
    'Engineering',
    'Product & Design',
    'Human Resources',
    'Marketing',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openEmployeeProfile(Employee emp) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: GlassContainer(
              borderRadius: 24,
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    children: [
                      AppAvatar(url: emp.avatarUrl, name: emp.name, radius: 30),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              emp.name,
                              style: AppTypography.titleLarge(
                                isDark,
                              ).copyWith(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${emp.designation} • ${emp.department}',
                              style: AppTypography.caption(isDark).copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: emp.status == 'On Leave'
                                    ? AppColors.warning.withValues(alpha: 0.15)
                                    : AppColors.success.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                emp.status,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: emp.status == 'On Leave'
                                      ? AppColors.warning
                                      : AppColors.success,
                                ),
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

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 14),

                  // Metadata Info List
                  _buildModalInfoRow(
                    Icons.badge_outlined,
                    'Employee Code',
                    emp.employeeCode,
                    isDark,
                  ),
                  _buildModalInfoRow(
                    Icons.email_outlined,
                    'Email Address',
                    emp.email,
                    isDark,
                  ),
                  _buildModalInfoRow(
                    Icons.phone_outlined,
                    'Contact Phone',
                    emp.phone,
                    isDark,
                  ),
                  _buildModalInfoRow(
                    Icons.location_on_outlined,
                    'Location',
                    emp.location,
                    isDark,
                  ),
                  _buildModalInfoRow(
                    Icons.event_available_outlined,
                    'Joined Date',
                    emp.joinDate,
                    isDark,
                  ),
                  _buildModalInfoRow(
                    Icons.supervisor_account_outlined,
                    'Manager',
                    emp.managerName,
                    isDark,
                  ),

                  const SizedBox(height: 18),

                  // Action Buttons: Call, Email, Message
                  Row(
                    children: [
                      Expanded(
                        child: AppButton.outlined(
                          label: 'Call',
                          icon: Icons.phone_rounded,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          onPressed: () {
                            _appController.showToast(
                              'Calling ${emp.name}',
                              'Initiating call to ${emp.phone}...',
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
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          onPressed: () {
                            _appController.showToast(
                              'Compose Email',
                              'Opening email client to mail ${emp.email}...',
                              ToastType.info,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppButton.outlined(
                          label: 'Chat',
                          icon: Icons.chat_bubble_rounded,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          onPressed: () {
                            _appController.showToast(
                              'Instant Message',
                              'Opening direct message chat with ${emp.name}...',
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

  Widget _buildModalInfoRow(
    IconData icon,
    String label,
    String value,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: AppTypography.caption(
                isDark,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium(
                isDark,
              ).copyWith(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final employees = _data.filteredEmployees;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Search Bar
              AppSearchField(
                controller: _searchController,
                hint: 'Search name, role, email...',
                onChanged: (val) {
                  setState(() => _data.employeeSearchQuery = val);
                },
              ),

              const SizedBox(height: 16),

              // 2. Department Filter Pills Row
              _buildDepartmentFilterPills(isDark),

              const SizedBox(height: 16),

              // 3. Employee Directory List
              _buildEmployeeSection(
                'Personnel (${employees.length})',
                employees,
                isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDepartmentFilterPills(bool isDark) {
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
          children: _departments.map((dept) {
            final isSelected = _data.employeeDeptFilter == dept;

            return GestureDetector(
              onTap: () {
                setState(() => _data.employeeDeptFilter = dept);
              },
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
                child: Text(
                  dept,
                  style: AppTypography.labelLarge(isDark).copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight)
                        : (isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmployeeSection(
    String sectionHeader,
    List<Employee> employees,
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
        if (employees.isEmpty)
          GlassContainer(
            borderRadius: 14,
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                children: [
                  Text(
                    'No employees found matching criteria.',
                    style: AppTypography.bodyMedium(isDark),
                  ),
                  const SizedBox(height: 10),
                  AppButton.text(
                    label: 'Clear Filters',
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _data.employeeSearchQuery = '';
                        _data.employeeDeptFilter = 'All';
                      });
                    },
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: employees
                .map((emp) => _buildEmployeeCard(emp, isDark))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildEmployeeCard(Employee emp, bool isDark) {
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
          onTap: () => _openEmployeeProfile(emp),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                AppAvatar(url: emp.avatarUrl, name: emp.name, radius: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        emp.name,
                        style: AppTypography.titleMedium(
                          isDark,
                        ).copyWith(fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        emp.designation,
                        style: AppTypography.caption(isDark).copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildMetaBadge(
                            Icons.corporate_fare_outlined,
                            emp.department,
                            isDark,
                          ),
                          const SizedBox(width: 12),
                          _buildMetaBadge(
                            Icons.location_on_outlined,
                            emp.location,
                            isDark,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 12,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              emp.email,
                              style: AppTypography.bodyMedium(isDark).copyWith(
                                fontSize: 11,
                                color: isDark
                                    ? AppColors.textMutedDark
                                    : AppColors.textMutedLight,
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

  Widget _buildMetaBadge(IconData icon, String label, bool isDark) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: AppTypography.caption(isDark).copyWith(
                fontSize: 11,
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
