import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/app_controller.dart';
import '../controllers/app_data_controller.dart';
import '../controllers/user_controller.dart';
import '../models/employee.dart';
import '../models/toast_notification.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/common/app_avatar.dart';
import '../widgets/common/custom_buttons.dart';
import '../widgets/common/custom_cupertino_date_picker.dart';
import '../widgets/common/custom_inputs.dart';
import '../widgets/common/custom_tabs.dart';
import '../widgets/common/ui_glass_container.dart';

class EmployeeProfileEditScreen extends StatefulWidget {
  const EmployeeProfileEditScreen({super.key});

  @override
  State<EmployeeProfileEditScreen> createState() =>
      _EmployeeProfileEditScreenState();
}

class _EmployeeProfileEditScreenState extends State<EmployeeProfileEditScreen> {
  final Map<String, TextEditingController> _controllers = {};
  int _activeTab = 0;

  Map<String, dynamic> get _profile =>
      Get.find<UserController>().employeeProfileData;
  Map<String, dynamic> get _family =>
      Get.find<UserController>().employeeFamilyData;
  Employee get _employee => Get.find<AppDataController>().currentUser;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _value(Map<String, dynamic> values, String key) =>
      values[key]?.toString() ?? '';

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
    String title,
  ) async {
    final now = DateTime.now();
    try {
      final DateTime? picked = await showCustomCupertinoDatePicker(
        context: context,
        controller: controller,
        title: title,
        minDate: DateTime(1940),
        maxDate: now.add(const Duration(days: 365 * 10)),
        showTime: false,
        dateFormat: 'yyyy-MM-dd',
      );
      if (picked != null) {
        setState(() {
          controller.text = DateFormat('yyyy-MM-dd').format(picked);
        });
      }
    } catch (e) {
      debugPrint('Date picker error: $e');
    }
  }

  Widget _field(
    String label,
    String key,
    Map<String, dynamic> values, {
    IconData? icon,
    int maxLines = 1,
  }) {
    final controller = _controllers.putIfAbsent(
      key,
      () => TextEditingController(text: _value(values, key)),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppTextField(
        label: label,
        controller: controller,
        prefixIcon: icon,
        maxLines: maxLines,
      ),
    );
  }

  Widget _datePickerField(
    String label,
    String key,
    Map<String, dynamic> values, {
    String title = 'Select Date',
    IconData icon = Icons.cake_outlined,
  }) {
    final controller = _controllers.putIfAbsent(
      key,
      () => TextEditingController(text: _value(values, key)),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _selectDate(context, controller, title),
        borderRadius: BorderRadius.circular(10),
        child: IgnorePointer(
          child: AppTextField(
            label: label,
            controller: controller,
            prefixIcon: icon,
            suffixIcon: const Icon(
              Icons.calendar_month_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        title,
        style: AppTypography.titleMedium(isDark).copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildPersonalFields(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('1. Identity & Names', isDark),
        GlassContainer(
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _field(
                'Full Name',
                'employee_name',
                _profile,
                icon: Icons.person_outline_rounded,
              ),
              _field(
                'Name (Local)',
                'employee_name_locale',
                _profile,
                icon: Icons.translate_rounded,
              ),
              _field(
                'Gender',
                'gender_text',
                _profile,
                icon: Icons.people_outline_rounded,
              ),
              _field(
                'Marital Status',
                'marital_status_text',
                _profile,
                icon: Icons.favorite_border_rounded,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        _buildSectionLabel('2. Contact Information', isDark),
        GlassContainer(
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _field(
                'Work Email Address',
                'email',
                _profile,
                icon: Icons.email_outlined,
              ),
              _field(
                'Personal Email Address',
                'email_per',
                _profile,
                icon: Icons.alternate_email_rounded,
              ),
              _field(
                'Phone Number',
                'phone',
                _profile,
                icon: Icons.phone_outlined,
              ),
              _field(
                'Secondary Phone',
                'phone_2',
                _profile,
                icon: Icons.phone_android_outlined,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        _buildSectionLabel('3. Date of Birth', isDark),
        GlassContainer(
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _datePickerField(
                'Date of Birth (AD)',
                'dob_ad',
                _profile,
                title: 'Select Date of Birth (AD)',
                icon: Icons.cake_outlined,
              ),
              _datePickerField(
                'Date of Birth (BS)',
                'dob_bs',
                _profile,
                title: 'Select Date of Birth (BS)',
                icon: Icons.calendar_month_outlined,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        _buildSectionLabel('4. Address Details', isDark),
        GlassContainer(
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _field(
                'Current Address',
                'address_current',
                _profile,
                icon: Icons.location_on_outlined,
              ),
              _field(
                'Permanent Address',
                'address_permanent',
                _profile,
                icon: Icons.home_outlined,
              ),
              _field(
                'Municipality',
                'municipality_name',
                _profile,
                icon: Icons.location_city_outlined,
              ),
              _field(
                'District',
                'district_name',
                _profile,
                icon: Icons.map_outlined,
              ),
              _field(
                'Province',
                'province_name',
                _profile,
                icon: Icons.public_outlined,
              ),
              _field(
                'Zone',
                'zone_name',
                _profile,
                icon: Icons.explore_outlined,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmploymentFields(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('1. Employment & Designation', isDark),
        GlassContainer(
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _field(
                'Employee Code',
                'employee_code',
                _profile,
                icon: Icons.badge_outlined,
              ),
              _field(
                'Current Designation',
                'current_designation_name',
                _profile,
                icon: Icons.work_outline_rounded,
              ),
              _field(
                'First Designation',
                'first_designation_name',
                _profile,
                icon: Icons.work_history_outlined,
              ),
              _field(
                'Previous Designation',
                'previous_designation_name',
                _profile,
                icon: Icons.history_edu_rounded,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        _buildSectionLabel('2. Joining Date & Supervisor', isDark),
        GlassContainer(
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _datePickerField(
                'Joining Date',
                'date_joined',
                _profile,
                title: 'Select Joining Date',
                icon: Icons.event_available_outlined,
              ),
              _field(
                'Reporting Manager / Supervisor',
                'supervisor_ids_text',
                _profile,
                icon: Icons.supervisor_account_outlined,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFamilyFields(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('1. Spouse Details', isDark),
        GlassContainer(
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _field(
                'Employee ID',
                'employee_id',
                _family,
                icon: Icons.badge_outlined,
              ),
              _field(
                'Spouse Name',
                'spouse_name',
                _family,
                icon: Icons.person_outline_rounded,
              ),
              _field(
                'Spouse Name (Local)',
                'spouse_name_locale',
                _family,
                icon: Icons.translate_rounded,
              ),
              _field(
                'Spouse Contact Number',
                'spouse_contact_num',
                _family,
                icon: Icons.phone_outlined,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        _buildSectionLabel('2. Parents & Grandparents', isDark),
        GlassContainer(
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _field(
                'Father Name',
                'father_name',
                _family,
                icon: Icons.person_outline_rounded,
              ),
              _field(
                'Father Name (Local)',
                'father_name_locale',
                _family,
                icon: Icons.translate_rounded,
              ),
              _field(
                'Mother Name',
                'mother_name',
                _family,
                icon: Icons.person_outline_rounded,
              ),
              _field(
                'Mother Name (Local)',
                'mother_name_locale',
                _family,
                icon: Icons.translate_rounded,
              ),
              _field(
                'Grandfather Name',
                'grandfather_name',
                _family,
                icon: Icons.person_outline_rounded,
              ),
              _field(
                'Grandmother Name',
                'grandmother_name',
                _family,
                icon: Icons.person_outline_rounded,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentFields(BuildContext context, bool isDark) {
    final documents = _employee.documents;
    if (documents.isEmpty) {
      return _emptyMessage(context, 'No documents available.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < documents.length; i++) ...[
          _buildSectionLabel('Document ${i + 1}: ${documents[i].title}', isDark),
          GlassContainer(
            borderRadius: 16,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _field('Title', 'document_${i}_title', {
                  'document_${i}_title': documents[i].title,
                }, icon: Icons.title_rounded),
                _field('Category', 'document_${i}_category', {
                  'document_${i}_category': documents[i].category,
                }, icon: Icons.category_outlined),
                _field('File Name', 'document_${i}_file_name', {
                  'document_${i}_file_name': documents[i].fileName,
                }, icon: Icons.insert_drive_file_outlined),
                _datePickerField(
                  'Uploaded Date',
                  'document_${i}_uploaded_date',
                  {'document_${i}_uploaded_date': documents[i].uploadedDate},
                  title: 'Select Uploaded Date',
                  icon: Icons.calendar_month_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildQualificationFields(BuildContext context, bool isDark) {
    final qualifications = _employee.qualifications;
    if (qualifications.isEmpty) {
      return _emptyMessage(context, 'No qualifications available.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < qualifications.length; i++) ...[
          _buildSectionLabel(
            'Qualification ${i + 1}: ${qualifications[i].degree}',
            isDark,
          ),
          GlassContainer(
            borderRadius: 16,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _field('Degree', 'qualification_${i}_degree', {
                  'qualification_${i}_degree': qualifications[i].degree,
                }, icon: Icons.school_outlined),
                _field('Institution', 'qualification_${i}_institution', {
                  'qualification_${i}_institution': qualifications[i].institution,
                }, icon: Icons.account_balance_outlined),
                _field('Year', 'qualification_${i}_year', {
                  'qualification_${i}_year': qualifications[i].year,
                }, icon: Icons.calendar_today_outlined),
                _field('Grade / Score', 'qualification_${i}_grade', {
                  'qualification_${i}_grade': qualifications[i].grade,
                }, icon: Icons.grade_outlined),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildExperienceFields(BuildContext context, bool isDark) {
    final experiences = _employee.experiences;
    if (experiences.isEmpty) {
      return _emptyMessage(context, 'No experience records available.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < experiences.length; i++) ...[
          _buildSectionLabel(
            'Experience ${i + 1}: ${experiences[i].company}',
            isDark,
          ),
          GlassContainer(
            borderRadius: 16,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _field('Company', 'experience_${i}_company', {
                  'experience_${i}_company': experiences[i].company,
                }, icon: Icons.business_outlined),
                _field('Role', 'experience_${i}_role', {
                  'experience_${i}_role': experiences[i].role,
                }, icon: Icons.work_outline_rounded),
                _field('Period', 'experience_${i}_period', {
                  'experience_${i}_period': experiences[i].period,
                }, icon: Icons.date_range_outlined),
                _field(
                  'Summary',
                  'experience_${i}_summary',
                  {'experience_${i}_summary': experiences[i].summary},
                  icon: Icons.notes_outlined,
                  maxLines: 3,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _emptyMessage(BuildContext context, String text) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: GlassContainer(
            borderRadius: 16,
            padding: const EdgeInsets.all(24),
            child: Text(
              text,
              style: AppTypography.bodyMedium(
                Theme.of(context).brightness == Brightness.dark,
              ),
            ),
          ),
        ),
      );

  Widget _activeFields(BuildContext context, bool isDark) => switch (_activeTab) {
        0 => _buildPersonalFields(isDark),
        1 => _buildEmploymentFields(isDark),
        2 => _buildDocumentFields(context, isDark),
        3 => _buildQualificationFields(context, isDark),
        4 => _buildExperienceFields(context, isDark),
        5 => _buildFamilyFields(isDark),
        _ => _buildPersonalFields(isDark),
      };

  Widget _buildHeaderCard(BuildContext context) {
    final name = _value(_profile, 'employee_name');
    final displayName = name.isNotEmpty ? name.toUpperCase() : 'ANIK SHAKYA';
    final designation = _value(_profile, 'current_designation_name');
    final displayRole =
        designation.isNotEmpty ? designation.toLowerCase() : 'employee';
    final email = _value(_profile, 'email');
    final displayEmail = email.isNotEmpty ? email : 'anik_mi@yonefu.info';
    final avatarUrl = _value(_profile, 'image_name_url');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 400;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar with Attached Red Circle Edit Pencil Button
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Hero(
                    tag: employeeProfileAvatarHeroTag,
                    child: AppAvatar(
                      url: avatarUrl,
                      name: displayName,
                      radius: isNarrow ? 40 : 48,
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: GestureDetector(
                      onTap: () {
                        Get.find<AppController>().showToast(
                          'Update Avatar',
                          'Select a photo to update your profile image.',
                          ToastType.info,
                        );
                      },
                      child: Container(
                        width: isNarrow ? 32 : 36,
                        height: isNarrow ? 32 : 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE53935), // Vibrant Red edit circle
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black38,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                          size: isNarrow ? 16 : 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: isNarrow ? 14 : 20),
              // User Details Column: Bold Uppercase Name, Red Subtitle, White Email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isNarrow ? 20 : 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayRole,
                      style: TextStyle(
                        color: const Color(0xFFE53935), // Red subtitle
                        fontSize: isNarrow ? 15 : 17,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayEmail,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isNarrow ? 15 : 17,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onUpdatePressed() {
    const sections = [
      'Personal Information',
      'Employment Details',
      'Documents',
      'Qualifications',
      'Experience',
      'Family Details',
    ];
    Get.find<AppController>().showToast(
      'Profile Updated',
      'Changes to ${sections[_activeTab]} saved successfully.',
      ToastType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 750),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Card matching attached reference image
                _buildHeaderCard(context),

                const SizedBox(height: 16),

                // 2. Custom Tab Bar
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

                // 3. Tab Content Form Cards matching Apply Leave UI style
                _activeFields(context, isDark),

                const SizedBox(height: 24),

                // 4. Submit / Save Button
                AppButton.primary(
                  label:
                      'Update ${['Personal', 'Employment', 'Documents', 'Qualifications', 'Experience', 'Family'][_activeTab]} Details',
                  icon: Icons.save_rounded,
                  isFullWidth: true,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  borderRadius: 16,
                  onPressed: _onUpdatePressed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

