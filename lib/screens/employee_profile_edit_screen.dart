import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/app_controller.dart';
import '../controllers/app_data_controller.dart';
import '../controllers/user_controller.dart';
import '../models/employee.dart';
import '../models/toast_notification.dart';
import '../theme/app_typography.dart';
import '../widgets/common/app_avatar.dart';
import '../widgets/common/custom_buttons.dart';
import '../widgets/common/custom_inputs.dart';
import '../widgets/common/custom_tabs.dart';

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

  Widget _field(String label, String key, Map<String, dynamic> values) {
    final controller = _controllers.putIfAbsent(
      key,
      () => TextEditingController(text: _value(values, key)),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppTextField(label: label, controller: controller),
    );
  }

  Widget _buildPersonalFields() {
    const fields = [
      ('Full Name', 'employee_name'),
      ('Name (Local)', 'employee_name_locale'),
      ('Gender', 'gender_text'),
      ('Marital Status', 'marital_status_text'),
      ('Email Address', 'email'),
      ('Personal Email', 'email_per'),
      ('Phone Number', 'phone'),
      ('Secondary Phone', 'phone_2'),
      ('Date of Birth (AD)', 'dob_ad'),
      ('Date of Birth (BS)', 'dob_bs'),
      ('Current Address', 'address_current'),
      ('Permanent Address', 'address_permanent'),
      ('Municipality', 'municipality_name'),
      ('District', 'district_name'),
      ('Province', 'province_name'),
      ('Zone', 'zone_name'),
    ];
    return Column(
      children: fields
          .map((field) => _field(field.$1, field.$2, _profile))
          .toList(),
    );
  }

  Widget _buildEmploymentFields() {
    const fields = [
      ('Employee Code', 'employee_code'),
      ('First Designation', 'first_designation_name'),
      ('Previous Designation', 'previous_designation_name'),
      ('Current Designation', 'current_designation_name'),
      ('Joining Date', 'date_joined'),
      ('Reporting Manager', 'supervisor_ids_text'),
    ];
    return Column(
      children: fields
          .map((field) => _field(field.$1, field.$2, _profile))
          .toList(),
    );
  }

  Widget _buildFamilyFields() {
    const fields = [
      ('Employee ID', 'employee_id'),
      ('Spouse Name', 'spouse_name'),
      ('Spouse Name (Local)', 'spouse_name_locale'),
      ('Spouse Contact Number', 'spouse_contact_num'),
      ('Father Name', 'father_name'),
      ('Father Name (Local)', 'father_name_locale'),
      ('Mother Name', 'mother_name'),
      ('Mother Name (Local)', 'mother_name_locale'),
      ('Grandfather Name', 'grandfather_name'),
      ('Grandmother Name', 'grandmother_name'),
    ];
    return Column(
      children: fields
          .map((field) => _field(field.$1, field.$2, _family))
          .toList(),
    );
  }

  Widget _buildDocumentFields(BuildContext context) {
    final documents = _employee.documents;
    if (documents.isEmpty) {
      return _emptyMessage(context, 'No documents available.');
    }
    return Column(
      children: [
        for (var i = 0; i < documents.length; i++) ...[
          _sectionHeading(context, 'Document ${i + 1}'),
          _field('Title', 'document_${i}_title', {
            'document_${i}_title': documents[i].title,
          }),
          _field('Category', 'document_${i}_category', {
            'document_${i}_category': documents[i].category,
          }),
          _field('File Name', 'document_${i}_file_name', {
            'document_${i}_file_name': documents[i].fileName,
          }),
          _field('Uploaded Date', 'document_${i}_uploaded_date', {
            'document_${i}_uploaded_date': documents[i].uploadedDate,
          }),
        ],
      ],
    );
  }

  Widget _buildQualificationFields(BuildContext context) {
    final qualifications = _employee.qualifications;
    if (qualifications.isEmpty) {
      return _emptyMessage(context, 'No qualifications available.');
    }
    return Column(
      children: [
        for (var i = 0; i < qualifications.length; i++) ...[
          _sectionHeading(context, 'Qualification ${i + 1}'),
          _field('Degree', 'qualification_${i}_degree', {
            'qualification_${i}_degree': qualifications[i].degree,
          }),
          _field('Institution', 'qualification_${i}_institution', {
            'qualification_${i}_institution': qualifications[i].institution,
          }),
          _field('Year', 'qualification_${i}_year', {
            'qualification_${i}_year': qualifications[i].year,
          }),
          _field('Grade', 'qualification_${i}_grade', {
            'qualification_${i}_grade': qualifications[i].grade,
          }),
        ],
      ],
    );
  }

  Widget _buildExperienceFields(BuildContext context) {
    final experiences = _employee.experiences;
    if (experiences.isEmpty) {
      return _emptyMessage(context, 'No experience available.');
    }
    return Column(
      children: [
        for (var i = 0; i < experiences.length; i++) ...[
          _sectionHeading(context, 'Experience ${i + 1}'),
          _field('Company', 'experience_${i}_company', {
            'experience_${i}_company': experiences[i].company,
          }),
          _field('Role', 'experience_${i}_role', {
            'experience_${i}_role': experiences[i].role,
          }),
          _field('Period', 'experience_${i}_period', {
            'experience_${i}_period': experiences[i].period,
          }),
          _field('Summary', 'experience_${i}_summary', {
            'experience_${i}_summary': experiences[i].summary,
          }),
        ],
      ],
    );
  }

  Widget _sectionHeading(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 12),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: AppTypography.titleMedium(
          Theme.of(context).brightness == Brightness.dark,
        ),
      ),
    ),
  );

  Widget _emptyMessage(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Text(
      text,
      style: AppTypography.bodyMedium(
        Theme.of(context).brightness == Brightness.dark,
      ),
    ),
  );

  Widget _activeFields(BuildContext context) => switch (_activeTab) {
    0 => _buildPersonalFields(),
    1 => _buildEmploymentFields(),
    2 => _buildDocumentFields(context),
    3 => _buildQualificationFields(context),
    4 => _buildExperienceFields(context),
    5 => _buildFamilyFields(),
    _ => _buildPersonalFields(),
  };

  Widget _buildProfileHero(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final name = _value(_profile, 'employee_name');
    final role = _value(_profile, 'current_designation_name');
    final email = _value(_profile, 'email');

    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 400;
        final avatarRadius = narrow ? 46.0 : 64.0;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Hero(
                  tag: employeeProfileAvatarHeroTag,
                  child: AppAvatar(
                    url: _value(_profile, 'image_name_url'),
                    name: name,
                    radius: avatarRadius,
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: 2,
                  child: Container(
                    width: narrow ? 34 : 42,
                    height: narrow ? 34 : 42,
                    decoration: BoxDecoration(
                      color: colors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      color: colors.onError,
                      size: narrow ? 18 : 22,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: narrow ? 16 : 28),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.toUpperCase(),
                    style: AppTypography.displayMedium(
                      isDark,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    role,
                    style: AppTypography.titleLarge(isDark).copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(email, style: AppTypography.titleLarge(isDark)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _onUpdatePressed() {
    const sections = [
      'personal information',
      'employment information',
      'documents',
      'qualifications',
      'experience',
      'family information',
    ];
    Get.find<AppController>().showToast(
      'Not Available Yet',
      'Updating ${sections[_activeTab]} is not connected yet.',
      ToastType.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(
                children: [
                  _buildProfileHero(context),
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
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _activeFields(context),
                            const SizedBox(height: 8),
                            AppButton.primary(
                              label:
                                  'Update ${['Personal', 'Employment', 'Documents', 'Qualifications', 'Experience', 'Family'][_activeTab]}',
                              icon: Icons.save_outlined,
                              onPressed: _onUpdatePressed,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
