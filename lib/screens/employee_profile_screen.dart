import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oms/controllers/auth_controller.dart';

import '../controllers/app_controller.dart';
import '../controllers/app_data_controller.dart';
import '../controllers/theme_controller.dart';
import '../controllers/user_controller.dart';
import '../models/employee.dart';
import '../models/toast_notification.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/common/app_avatar.dart';
import '../widgets/common/custom_buttons.dart';
import '../widgets/common/custom_loading.dart';
import '../widgets/common/custom_tabs.dart';
import '../widgets/common/ui_glass_container.dart';
import '../widgets/profile/edit_profile_dialog.dart';

class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({super.key});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  AppDataController get _data => Get.find<AppDataController>();
  AppController get _appController => Get.find<AppController>();
  ThemeController get _themeController => Get.find<ThemeController>();

  int _activeTab = 0;

  @override
  void initState() {
    super.initState();
    _refreshProfileData();
  }

  Future<void> _refreshProfileData() async {
    final userController = Get.find<UserController>();
    await Future.wait([
      userController.fetchEmployeeProfile(),
      userController.fetchEmployeeFamily(),
    ]);
  }

  void _showEditProfileModal() {
    showDialog(context: context, builder: (ctx) => const EditProfileDialog());
  }

  void _showLogoutConfirmation() {
    final authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          _LogoutConfirmationDialog(authController: authController),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Obx(() {
      final userController = Get.find<UserController>();
      if (userController.isEmployeeProfileLoading.value) {
        return RefreshIndicator(
          onRefresh: _refreshProfileData,
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
      if (userController.employeeProfileError.value.isNotEmpty) {
        return RefreshIndicator(
          onRefresh: _refreshProfileData,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          userController.employeeProfileError.value,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium(
                            isDark,
                          ).copyWith(color: AppColors.error),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _refreshProfileData,
                          child: const Text('Retry'),
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

      final profile = Map<String, dynamic>.from(
        userController.employeeProfileData,
      );

      return RefreshIndicator(
        onRefresh: _refreshProfileData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(context, isDark, profile),
                  const SizedBox(height: 16),
                  _buildThemeToggleCard(isDark),
                  const SizedBox(height: 16),
                  AppTabBar(
                    tabs: const [
                      'Personal',
                      'Employment',
                      'Documents',
                      'Qualifications',
                      'Experience',
                      'Family',
                    ],
                    selectedIndex: _activeTab,
                    onTabChanged: (index) => setState(() => _activeTab = index),
                  ),
                  const SizedBox(height: 16),
                  _buildActiveTabContent(context, isDark, profile),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildActiveTabContent(
    BuildContext context,
    bool isDark,
    Map<String, dynamic> profile,
  ) {
    return switch (_activeTab) {
      0 => _buildPersonalInfoTab(context, isDark, profile),
      1 => _buildEmploymentTab(context, isDark, profile),
      2 => _buildDocumentsTab(context, isDark, _data.currentUser),
      3 => _buildQualificationsTab(context, isDark, _data.currentUser),
      4 => _buildExperienceTab(context, isDark, _data.currentUser),
      5 => _buildFamilyTab(context, isDark),
      _ => _buildPersonalInfoTab(context, isDark, profile),
    };
  }

  Widget _buildProfileHeader(
    BuildContext context,
    bool isDark,
    Map<String, dynamic> profile,
  ) {
    final name = _profileValue(profile, 'employee_name');
    final designation = _profileValue(profile, 'current_designation_name');
    final employeeCode = _profileValue(profile, 'employee_code');
    final status = _profileValue(profile, 'active_text');
    final location =
        [
              profile['municipality_name'],
              profile['district_name'],
              profile['province_name'],
            ]
            .where(
              (value) => value != null && value.toString().trim().isNotEmpty,
            )
            .map((value) => value.toString().trim())
            .join(', ');

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
                        url: profile['image_name_url']?.toString() ?? '',
                        name: name,
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
                                name,
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
                                status,
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
                          designation,
                          style: AppTypography.titleMedium(isDark).copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Code: $employeeCode • $location',
                          style: AppTypography.caption(isDark),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppButton.primary(
                      label: 'Edit Profile',
                      icon: Icons.edit_outlined,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      onPressed: _showEditProfileModal,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: AppButton.outlined(
                      label: 'Log Out',
                      icon: Icons.logout_rounded,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      onPressed: _showLogoutConfirmation,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  String _profileValue(Map<String, dynamic> profile, String key) {
    final value = profile[key]?.toString().trim();
    return value == null || value.isEmpty ? 'Not provided' : value;
  }

  Widget _buildThemeToggleCard(bool isDark) {
    return GlassContainer(
      width: double.infinity,
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
    Map<String, dynamic> profile,
  ) {
    return GlassContainer(
      width: double.infinity,
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailGrid([
            _DetailItem(
              'Full Name',
              _profileValue(profile, 'employee_name'),
              Icons.person_outline_rounded,
            ),
            _DetailItem(
              'Name (Local)',
              _profileValue(profile, 'employee_name_locale'),
              Icons.translate_rounded,
            ),
            _DetailItem(
              'Gender',
              _profileValue(profile, 'gender_text'),
              Icons.people_outline_rounded,
            ),
            _DetailItem(
              'Marital Status',
              _profileValue(profile, 'marital_status_text'),
              Icons.favorite_border_rounded,
            ),
            _DetailItem(
              'Email Address',
              _profileValue(profile, 'email'),
              Icons.email_outlined,
            ),
            _DetailItem(
              'Personal Email',
              _profileValue(profile, 'email_per'),
              Icons.alternate_email_rounded,
            ),
            _DetailItem(
              'Phone Number',
              _profileValue(profile, 'phone'),
              Icons.phone_outlined,
            ),
            _DetailItem(
              'Secondary Phone',
              _profileValue(profile, 'phone_2'),
              Icons.phone_android_outlined,
            ),
            _DetailItem(
              'Date of Birth (AD)',
              _profileValue(profile, 'dob_ad'),
              Icons.cake_outlined,
            ),
            _DetailItem(
              'Date of Birth (BS)',
              _profileValue(profile, 'dob_bs'),
              Icons.calendar_month_outlined,
            ),
            _DetailItem(
              'Current Address',
              _profileValue(profile, 'address_current'),
              Icons.location_on_outlined,
            ),
            _DetailItem(
              'Permanent Address',
              _profileValue(profile, 'address_permanent'),
              Icons.home_outlined,
            ),
            _DetailItem(
              'Municipality',
              _profileValue(profile, 'municipality_name'),
              Icons.location_city_outlined,
            ),
            _DetailItem(
              'District',
              _profileValue(profile, 'district_name'),
              Icons.map_outlined,
            ),
            _DetailItem(
              'Province',
              _profileValue(profile, 'province_name'),
              Icons.public_outlined,
            ),
            _DetailItem(
              'Zone',
              _profileValue(profile, 'zone_name'),
              Icons.explore_outlined,
            ),
          ], isDark),
        ],
      ),
    );
  }

  Widget _buildEmploymentTab(
    BuildContext context,
    bool isDark,
    Map<String, dynamic> profile,
  ) {
    return GlassContainer(
      width: double.infinity,
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailGrid([
            _DetailItem(
              'Employee Code',
              _profileValue(profile, 'employee_code'),
              Icons.badge_outlined,
            ),
            _DetailItem(
              'First Designation',
              _profileValue(profile, 'first_designation_name'),
              Icons.work_outline_rounded,
            ),
            _DetailItem(
              'Previous Designation',
              _profileValue(profile, 'previous_designation_name'),
              Icons.work_outline_rounded,
            ),
            _DetailItem(
              'Current Designation',
              _profileValue(profile, 'current_designation_name'),
              Icons.work_outline_rounded,
            ),
            _DetailItem(
              'Joining Date',
              _profileValue(profile, 'date_joined'),
              Icons.event_available_outlined,
            ),
            _DetailItem(
              'Reporting Manager',
              _profileValue(profile, 'supervisor_ids_text'),
              Icons.supervisor_account_outlined,
            ),
          ], isDark),
        ],
      ),
    );
  }

  Widget _buildFamilyTab(BuildContext context, bool isDark) {
    final userController = Get.find<UserController>();
    return Obx(() {
      if (userController.isEmployeeFamilyLoading.value) {
        return GlassContainer(
          width: double.infinity,
          borderRadius: 16,
          padding: const EdgeInsets.all(32),
          child: loadingWidget(AppColors.primary),
        );
      }

      if (userController.employeeFamilyError.value.isNotEmpty) {
        return GlassContainer(
          width: double.infinity,
          borderRadius: 16,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                userController.employeeFamilyError.value,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium(
                  isDark,
                ).copyWith(color: AppColors.error),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: userController.fetchEmployeeFamily,
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      final family = Map<String, dynamic>.from(
        userController.employeeFamilyData,
      );
      return GlassContainer(
        width: double.infinity,
        borderRadius: 16,
        padding: const EdgeInsets.all(16),
        child: _buildDetailGrid([
          _DetailItem(
            'Employee ID *',
            _profileValue(family, 'employee_id'),
            Icons.badge_outlined,
          ),
          _DetailItem(
            'Spouse Name',
            _profileValue(family, 'spouse_name'),
            Icons.person_outline_rounded,
          ),
          _DetailItem(
            'Spouse Name (Local)',
            _profileValue(family, 'spouse_name_locale'),
            Icons.translate_rounded,
          ),
          _DetailItem(
            'Spouse Contact Number',
            _profileValue(family, 'spouse_contact_num'),
            Icons.phone_outlined,
          ),
          _DetailItem(
            'Father Name *',
            _profileValue(family, 'father_name'),
            Icons.person_outline_rounded,
          ),
          _DetailItem(
            'Father Name (Local) *',
            _profileValue(family, 'father_name_locale'),
            Icons.translate_rounded,
          ),
          _DetailItem(
            'Mother Name *',
            _profileValue(family, 'mother_name'),
            Icons.person_outline_rounded,
          ),
          _DetailItem(
            'Mother Name (Local) *',
            _profileValue(family, 'mother_name_locale'),
            Icons.translate_rounded,
          ),
          _DetailItem(
            'Grandfather Name *',
            _profileValue(family, 'grandfather_name'),
            Icons.person_outline_rounded,
          ),
          _DetailItem(
            'Grandmother Name *',
            _profileValue(family, 'grandmother_name'),
            Icons.person_outline_rounded,
          ),
        ], isDark),
      );
    });
  }

  Widget _buildDocumentsTab(BuildContext context, bool isDark, Employee emp) {
    if (emp.documents.isEmpty) {
      return GlassContainer(
        width: double.infinity,
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
            width: double.infinity,
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
        width: double.infinity,
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
            width: double.infinity,
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
        width: double.infinity,
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
            width: double.infinity,
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

class _LogoutConfirmationDialog extends StatelessWidget {
  final AuthController authController;

  const _LogoutConfirmationDialog({required this.authController});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: GlassContainer(
          width: double.infinity,
          borderRadius: 20,
          padding: const EdgeInsets.all(24),
          child: Obx(() {
            final isLoading = authController.isLogoutLoading.value;

            return PopScope(
              canPop: !isLoading,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      size: 28,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Log Out?',
                    textAlign: TextAlign.center,
                    style: AppTypography.titleLarge(isDark),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Are you sure you want to log out of your account?',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium(isDark),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton.outlined(
                          label: 'Cancel',
                          onPressed: isLoading
                              ? null
                              : () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton.primary(
                          label: 'Log Out',
                          icon: Icons.logout_rounded,
                          isLoading: isLoading,
                          onPressed: isLoading
                              ? null
                              : () => authController.logout(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _DetailItem {
  final String label;
  final String value;
  final IconData icon;

  _DetailItem(this.label, this.value, this.icon);
}
