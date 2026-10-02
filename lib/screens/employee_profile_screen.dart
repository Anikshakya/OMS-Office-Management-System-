import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oms/controllers/auth_controller.dart';
import '../controllers/app_data_controller.dart';
import '../controllers/app_controller.dart';
import '../controllers/theme_controller.dart';
import '../models/toast_notification.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/common/ui_glass_container.dart';
import '../widgets/common/custom_buttons.dart';
import '../widgets/common/custom_tabs.dart';
import '../widgets/common/app_avatar.dart';
import '../widgets/profile/edit_profile_dialog.dart';
import '../models/employee.dart';

class EmployeeProfileScreen extends StatefulWidget {
  final Employee? employee;

  const EmployeeProfileScreen({super.key, this.employee});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  AppDataController get _data => Get.find<AppDataController>();
  AppController get _appController => Get.find<AppController>();
  ThemeController get _themeController => Get.find<ThemeController>();

  int _activeTab = 0;

  void _showEditProfileModal() {
    showDialog(context: context, builder: (ctx) => const EditProfileDialog());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emp = widget.employee ?? _data.currentUser;
    final isSelf =
        widget.employee == null || widget.employee!.id == _data.currentUser.id;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Profile Header Card
              _buildProfileHeader(context, isDark, emp, isSelf),

              const SizedBox(height: 16),

              // Theme Settings Quick Bar (Placed directly in profile!)
              if (isSelf) ...[
                _buildThemeToggleCard(isDark),
                const SizedBox(height: 16),
              ],

              // Navigation Tabs
              AppTabBar(
                tabs: const [
                  'Personal',
                  'Employment',
                  'Documents',
                  'Qualifications',
                  'Experience',
                ],
                selectedIndex: _activeTab,
                onTabChanged: (index) => setState(() => _activeTab = index),
              ),

              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: () {
                  final authCon = Get.put(AuthController());
                  authCon.logout();
                },
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Tab Content Views
              IndexedStack(
                index: _activeTab,
                children: [
                  _buildPersonalInfoTab(context, isDark, emp),
                  _buildEmploymentTab(context, isDark, emp),
                  _buildDocumentsTab(context, isDark, emp),
                  _buildQualificationsTab(context, isDark, emp),
                  _buildExperienceTab(context, isDark, emp),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    bool isDark,
    Employee emp,
    bool isSelf,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [Colors.white, const Color(0xFFF8FAFC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
        boxShadow: AppColors.softShadow(isDark),
      ),
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 480;

          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      AppAvatar(
                        url: emp.avatarUrl,
                        name: emp.name,
                        radius: isNarrow ? 28 : 36,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 14,
                          height: 14,
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
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                emp.name,
                                style: AppTypography.displayMedium(
                                  isDark,
                                ).copyWith(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                emp.status,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${emp.designation} • ${emp.department}',
                          style: AppTypography.titleMedium(isDark).copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Code: ${emp.employeeCode} • ${emp.location}',
                          style: AppTypography.caption(isDark),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (isSelf) ...[
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.verified_user_rounded,
                          size: 16,
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          emp.employmentType,
                          style: AppTypography.caption(
                            isDark,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    AppButton.primary(
                      label: 'Edit Profile',
                      icon: Icons.edit_outlined,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      onPressed: _showEditProfileModal,
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildThemeToggleCard(bool isDark) {
    return GlassContainer(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.amber.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: isDark ? Colors.amber : AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App Appearance Theme',
                    style: AppTypography.titleMedium(
                      isDark,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    isDark ? 'Dark Mode Active' : 'Light Mode Active',
                    style: AppTypography.caption(isDark),
                  ),
                ],
              ),
            ],
          ),
          Switch.adaptive(
            value: isDark,
            activeTrackColor: AppColors.primary,
            onChanged: (_) => _themeController.toggleTheme(),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoTab(
    BuildContext context,
    bool isDark,
    Employee emp,
  ) {
    return GlassContainer(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailGrid([
            _DetailItem('Full Name', emp.name, Icons.person_outline_rounded),
            _DetailItem('Email Address', emp.email, Icons.email_outlined),
            _DetailItem('Phone Number', emp.phone, Icons.phone_outlined),
            _DetailItem('Date of Birth', emp.dob, Icons.cake_outlined),
            _DetailItem(
              'Current Location',
              emp.location,
              Icons.location_on_outlined,
            ),
            _DetailItem(
              'Residential Address',
              emp.address,
              Icons.home_outlined,
            ),
          ], isDark),
        ],
      ),
    );
  }

  Widget _buildEmploymentTab(BuildContext context, bool isDark, Employee emp) {
    return GlassContainer(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailGrid([
            _DetailItem(
              'Employee Code',
              emp.employeeCode,
              Icons.badge_outlined,
            ),
            _DetailItem(
              'Department',
              emp.department,
              Icons.corporate_fare_outlined,
            ),
            _DetailItem(
              'Designation',
              emp.designation,
              Icons.work_outline_rounded,
            ),
            _DetailItem(
              'Employment Type',
              emp.employmentType,
              Icons.card_membership_rounded,
            ),
            _DetailItem(
              'Joining Date',
              emp.joinDate,
              Icons.event_available_outlined,
            ),
            _DetailItem(
              'Reporting Manager',
              emp.managerName,
              Icons.supervisor_account_outlined,
            ),
          ], isDark),
        ],
      ),
    );
  }

  Widget _buildDocumentsTab(BuildContext context, bool isDark, Employee emp) {
    if (emp.documents.isEmpty) {
      return GlassContainer(
        borderRadius: 16,
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No documents uploaded for this employee.',
            style: AppTypography.bodyMedium(isDark),
          ),
        ),
      );
    }

    return Column(
      children: emp.documents.map((doc) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GlassContainer(
            borderRadius: 14,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.title,
                        style: AppTypography.titleMedium(
                          isDark,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${doc.fileName} • ${doc.fileSize}',
                        style: AppTypography.caption(isDark),
                      ),
                    ],
                  ),
                ),
                AppButton.outlined(
                  label: 'View',
                  icon: Icons.visibility_outlined,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  onPressed: () {
                    _appController.showToast(
                      'Document Viewer',
                      'Opening ${doc.title}...',
                      ToastType.info,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQualificationsTab(
    BuildContext context,
    bool isDark,
    Employee emp,
  ) {
    if (emp.qualifications.isEmpty) {
      return GlassContainer(
        borderRadius: 16,
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No qualifications listed.',
            style: AppTypography.bodyMedium(isDark),
          ),
        ),
      );
    }

    return Column(
      children: emp.qualifications.map((q) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GlassContainer(
            borderRadius: 14,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: AppColors.secondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        q.degree,
                        style: AppTypography.titleMedium(
                          isDark,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${q.institution} (${q.year}) • ${q.grade}',
                        style: AppTypography.caption(isDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExperienceTab(BuildContext context, bool isDark, Employee emp) {
    if (emp.experiences.isEmpty) {
      return GlassContainer(
        borderRadius: 16,
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No prior work experience listed.',
            style: AppTypography.bodyMedium(isDark),
          ),
        ),
      );
    }

    return Column(
      children: emp.experiences.map((exp) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GlassContainer(
            borderRadius: 14,
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.work_history_rounded,
                    color: AppColors.warning,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exp.role,
                        style: AppTypography.titleMedium(
                          isDark,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${exp.company} • ${exp.period}',
                        style: AppTypography.caption(isDark).copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exp.summary,
                        style: AppTypography.bodyMedium(isDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDetailGrid(List<_DetailItem> items, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        int cols = width > 550 ? 2 : 1;
        double itemWidth = (width - (cols - 1) * 14) / cols;

        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: items.map((item) {
            return SizedBox(
              width: itemWidth,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.bgLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      size: 18,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: AppTypography.caption(isDark),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.value,
                            style: AppTypography.bodyMedium(
                              isDark,
                            ).copyWith(fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _DetailItem {
  final String label;
  final String value;
  final IconData icon;

  _DetailItem(this.label, this.value, this.icon);
}
