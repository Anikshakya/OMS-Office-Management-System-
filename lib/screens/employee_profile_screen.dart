import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oms/controllers/auth_controller.dart';

import '../controllers/theme_controller.dart';
import '../controllers/user_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/common/app_avatar.dart';
import '../widgets/common/custom_buttons.dart';
import '../widgets/common/custom_loading.dart';
import '../widgets/common/ui_glass_container.dart';
import 'employee_profile_edit_screen.dart';

class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({super.key});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  // AppDataController get _data => Get.find<AppDataController>();
  // AppController get _appController => Get.find<AppController>();
  ThemeController get _themeController => Get.find<ThemeController>();

  bool _notificationsEnabled = true;
  bool _biometricsEnabled = false;
  String _selectedLanguage = 'Eng';
  String _selectedDateFormat = 'BS';

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
      userController.fetchEmployeeExperiences(),
      userController.fetchEmployeeEducations(),
      userController.fetchEmployeeDocuments(),
    ]);
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
                  // 1. Profile Header
                  _buildProfileHeader(context, isDark, profile),
                  const SizedBox(height: 20),
                  _buildThemeToggleCard(isDark),
                  const SizedBox(height: 20),
                  // 2. Settings Menu Card matching screenshot design
                  _buildSettingsCard(context, isDark),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSettingsCard(BuildContext context, bool isDark) {
    return GlassContainer(
      width: double.infinity,
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // 1. Notification
          _buildSettingSwitchRow(
            icon: Icons.notifications_none_rounded,
            label: 'Notification',
            value: _notificationsEnabled,
            onChanged: (val) => setState(() => _notificationsEnabled = val),
            isDark: isDark,
          ),
          Divider(
            height: 1,
            color: isDark ? Colors.white10 : AppColors.borderLight,
          ),
          // 3. Biometric
          _buildSettingSwitchRow(
            icon: Icons.fingerprint_rounded,
            label: 'Biometric',
            value: _biometricsEnabled,
            onChanged: (val) => setState(() => _biometricsEnabled = val),
            isDark: isDark,
          ),
          Divider(
            height: 1,
            color: isDark ? Colors.white10 : AppColors.borderLight,
          ),
          // 4. Language (Eng)
          _buildSettingSelectRow(
            icon: Icons.language_rounded,
            label: 'Language ($_selectedLanguage)',
            onTap: () => _showLanguagePicker(context, isDark),
            isDark: isDark,
          ),
          Divider(
            height: 1,
            color: isDark ? Colors.white10 : AppColors.borderLight,
          ),
          // 5. Date Preference (BS)
          _buildSettingSelectRow(
            icon: Icons.calendar_month_rounded,
            label: 'Date Preference ($_selectedDateFormat)',
            onTap: () => _showDateFormatPicker(context, isDark),
            isDark: isDark,
          ),
          Divider(
            height: 1,
            color: isDark ? Colors.white10 : AppColors.borderLight,
          ),
          // 6. About Us
          _buildSettingSelectRow(
            icon: Icons.info_outline_rounded,
            label: 'About Us',
            onTap: () => _showAboutUsDialog(context, isDark),
            isDark: isDark,
            showChevron: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingSwitchRow({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: AppColors.primary,
            // ignore: deprecated_member_use
            activeColor: Colors.white,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingSelectRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    bool showChevron = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (showChevron)
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: isDark ? Colors.white54 : AppColors.textMutedLight,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    bool isDark,
    Map<String, dynamic> profile,
  ) {
    final rawName = _profileValue(profile, 'employee_name');
    final name = rawName != 'Not provided'
        ? rawName.toUpperCase()
        : 'ANIK SHAKYA';
    final rawDesignation = _profileValue(profile, 'current_designation_name');
    final designation = rawDesignation != 'Not provided'
        ? rawDesignation.toLowerCase()
        : 'employee';
    final status = _profileValue(profile, 'active_text');
    final employeeCode = _profileValue(profile, 'employee_code');
    final location = [
      _profileValue(profile, 'municipality_name'),
      _profileValue(profile, 'province_name'),
    ].where((value) => value != 'Not provided').join(', ');
    final avatarUrl = profile['image_name_url']?.toString() ?? '';

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
                        url: avatarUrl,
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
                      onPressed: (){
                        Get.to(() => const EmployeeProfileEditScreen());
                      },
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

  String _profileValue(Map<String, dynamic> profile, String key) {
    final value = profile[key]?.toString().trim();
    return value == null || value.isEmpty ? 'Not provided' : value;
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

  void _showLanguagePicker(BuildContext context, bool isDark) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.language_rounded),
                title: const Text('English (Eng)'),
                trailing: _selectedLanguage == 'Eng'
                    ? const Icon(Icons.check_rounded, color: Color(0xFFE53935))
                    : null,
                onTap: () {
                  setState(() => _selectedLanguage = 'Eng');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.translate_rounded),
                title: const Text('Nepali (Nep)'),
                trailing: _selectedLanguage == 'Nep'
                    ? const Icon(Icons.check_rounded, color: Color(0xFFE53935))
                    : null,
                onTap: () {
                  setState(() => _selectedLanguage = 'Nep');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDateFormatPicker(BuildContext context, bool isDark) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month_rounded),
                title: const Text('Bikram Sambat (BS)'),
                trailing: _selectedDateFormat == 'BS'
                    ? const Icon(Icons.check_rounded, color: Color(0xFFE53935))
                    : null,
                onTap: () {
                  setState(() => _selectedDateFormat = 'BS');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today_rounded),
                title: const Text('Anno Domini (AD)'),
                trailing: _selectedDateFormat == 'AD'
                    ? const Icon(Icons.check_rounded, color: Color(0xFFE53935))
                    : null,
                onTap: () {
                  setState(() => _selectedDateFormat = 'AD');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAboutUsDialog(BuildContext context, bool isDark) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.business_rounded, color: Color(0xFFE53935)),
            const SizedBox(width: 10),
            const Text('About Us'),
          ],
        ),
        content: const Text(
          'Office Management System (OMS)\nVersion 2.4.0\n\nEmpowering corporate productivity with modern employee management tools.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
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
