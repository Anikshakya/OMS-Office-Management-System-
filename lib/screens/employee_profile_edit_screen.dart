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
import '../widgets/common/custom_item_picker.dart';
import '../widgets/common/custom_tabs.dart';
import '../widgets/common/ui_glass_container.dart';

class EmployeeProfileEditScreen extends StatefulWidget {
  const EmployeeProfileEditScreen({super.key});

  @override
  State<EmployeeProfileEditScreen> createState() =>
      _EmployeeProfileEditScreenState();
}

class _EmployeeProfileEditScreenState extends State<EmployeeProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  int _activeTab = 0;

  List<EmployeeDocument> _documentsList = [];

  Map<String, dynamic> get _profile =>
      Get.find<UserController>().employeeProfileData;
  Map<String, dynamic> get _family =>
      Get.find<UserController>().employeeFamilyData;
  Employee get _employee => Get.find<AppDataController>().currentUser;

  @override
  void initState() {
    super.initState();
    _documentsList = List<EmployeeDocument>.from(_employee.documents);
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _removeDocument(int index) {
    final removedDoc = _documentsList[index];
    setState(() {
      _documentsList.removeAt(index);
    });
    Get.find<AppController>().showToast(
      'Document Removed',
      '${removedDoc.title} has been deleted.',
      ToastType.info,
    );
  }

  void _showAddDocumentDialog(BuildContext context) {
    final titleController = TextEditingController();
    final categoryController = TextEditingController(text: 'Identity');
    final fileNameController = TextEditingController(text: 'scanned_doc.pdf');

    showDialog<void>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: GlassContainer(
              borderRadius: 20,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.note_add_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Add New Document',
                            style: AppTypography.titleMedium(
                              isDark,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'Document Title *',
                    controller: titleController,
                    hint: 'e.g. Passport / Academic Degree',
                    prefixIcon: Icons.title_rounded,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Category',
                    controller: categoryController,
                    hint: 'e.g. Identity, Tax, Academic',
                    prefixIcon: Icons.category_outlined,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'File Name',
                    controller: fileNameController,
                    hint: 'e.g. passport_scan.pdf',
                    prefixIcon: Icons.insert_drive_file_outlined,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AppButton.outlined(
                        label: 'Cancel',
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 12),
                      AppButton.primary(
                        label: 'Upload Document',
                        icon: Icons.add_rounded,
                        onPressed: () {
                          final title = titleController.text.trim();
                          if (title.isEmpty) {
                            Get.find<AppController>().showToast(
                              'Validation Error',
                              'Please enter a document title.',
                              ToastType.error,
                            );
                            return;
                          }
                          final now = DateTime.now();
                          final formattedDate =
                              '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
                          final newDoc = EmployeeDocument(
                            title: title,
                            category: categoryController.text.trim().isNotEmpty
                                ? categoryController.text.trim()
                                : 'General',
                            fileName: fileNameController.text.trim().isNotEmpty
                                ? fileNameController.text.trim()
                                : 'document.pdf',
                            fileSize: '1.2 MB',
                            uploadedDate: formattedDate,
                          );
                          setState(() {
                            _documentsList.add(newDoc);
                          });
                          Navigator.pop(context);
                          Get.find<AppController>().showToast(
                            'Document Uploaded',
                            '$title added successfully.',
                            ToastType.success,
                          );
                        },
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

  String _value(Map<String, dynamic> values, String key) =>
      values[key]?.toString() ?? '';

  String _profileOrControllerValue(String key) {
    final controller = _controllers[key];
    return controller == null ? _value(_profile, key) : controller.text.trim();
  }

  String _genderLabel() {
    final value = _value(_profile, 'gender_text').trim().toLowerCase();
    final code = _value(_profile, 'gender').trim().toLowerCase();
    return switch (value.isNotEmpty ? value : code) {
      'm' || 'male' => 'Male',
      'f' || 'female' => 'Female',
      'o' || 'other' => 'Other',
      'n' || 'not specified' => 'Not Specified',
      _ => '',
    };
  }

  String _maritalStatusLabel() {
    final value = _value(_profile, 'marital_status_text').trim().toLowerCase();
    final code = _value(_profile, 'marital_status').trim().toLowerCase();
    return switch (value.isNotEmpty ? value : code) {
      '1' || 'unmarried' || 'single' => 'Unmarried',
      '2' || 'married' => 'Married',
      '3' || 'not specified' => 'Not Specified',
      _ => '',
    };
  }

  String? _requiredValidator(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;

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

  Future<int?> _selectYear(
    BuildContext context, {
    required int initialYear,
    required String title,
    int minYear = 1940,
    int? maxYear,
  }) async {
    final yearController = TextEditingController(text: '$initialYear');
    try {
      final picked = await showCustomCupertinoDatePicker(
        context: context,
        controller: yearController,
        title: title,
        minDate: DateTime(minYear),
        maxDate: DateTime(maxYear ?? DateTime.now().year),
        dateFormat: 'yyyy',
      );
      return picked?.year;
    } finally {
      yearController.dispose();
    }
  }

  Widget _selectionPickerField(
    String label,
    String key,
    Map<String, dynamic> values,
    List<String> options, {
    required String title,
    IconData? icon,
    bool requiredField = false,
  }) {
    final controller = _controllers.putIfAbsent(
      key,
      () => TextEditingController(text: _value(values, key)),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          final selected = await showCustomCupertinoItemPicker<String>(
            context: context,
            items: options,
            initialItem: controller.text,
            itemLabelBuilder: (item) => item,
            title: title,
          );
          if (selected != null && mounted) {
            setState(() => controller.text = selected);
          }
        },
        borderRadius: BorderRadius.circular(10),
        child: IgnorePointer(
          child: AppTextField(
            label: label,
            controller: controller,
            prefixIcon: icon,
            validator: requiredField ? _requiredValidator : null,
            suffixIcon: const Icon(
              Icons.arrow_drop_down_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _yearPickerField(
    String label,
    String key,
    Map<String, dynamic> values, {
    required String title,
    IconData icon = Icons.calendar_today_outlined,
  }) {
    final controller = _controllers.putIfAbsent(
      key,
      () => TextEditingController(text: _value(values, key)),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          final parsedYear = int.tryParse(controller.text.trim());
          final year = await _selectYear(
            context,
            initialYear: parsedYear ?? DateTime.now().year,
            title: title,
          );
          if (year != null && mounted) {
            setState(() => controller.text = '$year');
          }
        },
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

  Future<void> _selectExperiencePeriod(
    TextEditingController controller,
    int index,
  ) async {
    final years = RegExp(r'\d{4}')
        .allMatches(controller.text)
        .map((match) => int.parse(match.group(0)!))
        .toList();
    final currentYear = DateTime.now().year;
    final startYear = years.isNotEmpty ? years.first : currentYear;
    final endYear = years.length > 1 ? years[1] : startYear;

    final selectedStartYear = await _selectYear(
      context,
      initialYear: startYear,
      title: 'Select Experience ${index + 1} Start Year',
    );
    if (selectedStartYear == null || !mounted) return;

    final selectedEndYear = await _selectYear(
      context,
      initialYear: endYear < selectedStartYear ? selectedStartYear : endYear,
      title: 'Select Experience ${index + 1} End Year',
      minYear: selectedStartYear,
    );
    if (selectedEndYear != null && mounted) {
      setState(() {
        controller.text = '$selectedStartYear - $selectedEndYear';
      });
    }
  }

  Widget _experiencePeriodPickerField(int index, WorkExperience experience) {
    final key = 'experience_${index}_period';
    final controller = _controllers.putIfAbsent(
      key,
      () => TextEditingController(text: experience.period),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _selectExperiencePeriod(controller, index),
        borderRadius: BorderRadius.circular(10),
        child: IgnorePointer(
          child: AppTextField(
            label: 'Period',
            controller: controller,
            prefixIcon: Icons.date_range_outlined,
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

  Widget _field(
    String label,
    String key,
    Map<String, dynamic> values, {
    IconData? icon,
    int maxLines = 1,
    bool requiredField = false,
    bool integerField = false,
    bool? isReadOnly,
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
        readOnly: isReadOnly ?? false,
        validator: requiredField
            ? (value) {
                final requiredError = _requiredValidator(value);
                if (requiredError != null) return requiredError;
                if (integerField && int.tryParse(value!.trim()) == null) {
                  return 'Enter a valid ID';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _datePickerField(
    String label,
    String key,
    Map<String, dynamic> values, {
    String title = 'Select Date',
    IconData icon = Icons.cake_outlined,
    bool requiredField = false,
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
            validator: requiredField ? _requiredValidator : null,
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
        style: AppTypography.titleMedium(
          isDark,
        ).copyWith(fontWeight: FontWeight.w700),
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
                'Full Name *',
                'employee_name',
                _profile,
                icon: Icons.person_outline_rounded,
                requiredField: true,
              ),
              _field(
                'Name (Local) *',
                'employee_name_locale',
                _profile,
                icon: Icons.translate_rounded,
                requiredField: true,
              ),
              _selectionPickerField(
                'Gender *',
                'gender_text',
                {'gender_text': _genderLabel()},
                const ['Male', 'Female', 'Other', 'Not Specified'],
                title: 'Select Gender',
                icon: Icons.people_outline_rounded,
                requiredField: true,
              ),
              _selectionPickerField(
                'Marital Status *',
                'marital_status_text',
                {'marital_status_text': _maritalStatusLabel()},
                const ['Unmarried', 'Married', 'Not Specified'],
                title: 'Select Marital Status',
                icon: Icons.favorite_border_rounded,
                requiredField: true,
              ),
              _field(
                'Employee Code *',
                'employee_code',
                _profile,
                icon: Icons.badge_outlined,
                requiredField: true,
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
                'Phone Number *',
                'phone',
                _profile,
                icon: Icons.phone_outlined,
                requiredField: true,
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
        _buildSectionLabel('4. Employment Details', isDark),
        GlassContainer(
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _datePickerField(
                'Joining Date *',
                'date_joined',
                _profile,
                title: 'Select Joining Date',
                icon: Icons.event_available_outlined,
                requiredField: true,
              ),
              _datePickerField(
                'Resignation Date',
                'date_resigned',
                _profile,
                title: 'Select Resignation Date',
                icon: Icons.event_busy_outlined,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        _buildSectionLabel('5. Address Details', isDark),
        GlassContainer(
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _field(
                'Current Address *',
                'address_current',
                _profile,
                icon: Icons.location_on_outlined,
                requiredField: true,
              ),
              _field(
                'Permanent Address *',
                'address_permanent',
                _profile,
                icon: Icons.home_outlined,
                requiredField: true,
              ),
              _field(
                'Zone ID *',
                'zone_id',
                _profile,
                icon: Icons.explore_outlined,
                requiredField: true,
                integerField: true,
              ),
              _field(
                'District ID *',
                'district_id',
                _profile,
                icon: Icons.map_outlined,
                requiredField: true,
                integerField: true,
              ),
              _field(
                'Province ID *',
                'province_id',
                _profile,
                icon: Icons.public_outlined,
                requiredField: true,
                integerField: true,
              ),
              _field(
                'Municipality ID *',
                'municipality_id',
                _profile,
                icon: Icons.location_city_outlined,
                requiredField: true,
                integerField: true,
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
                'Current Designation',
                'current_designation_name',
                _profile,
                icon: Icons.work_outline_rounded,
                isReadOnly: true
              ),
              _field(
                'First Designation',
                'first_designation_name',
                _profile,
                icon: Icons.work_history_outlined,
                isReadOnly: true
              ),
              _field(
                'Previous Designation',
                'previous_designation_name',
                _profile,
                icon: Icons.history_edu_rounded,
                isReadOnly: true
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
              _field(
                'Reporting Manager / Supervisor',
                'supervisor_ids_text',
                _profile,
                icon: Icons.supervisor_account_outlined,
                isReadOnly: true
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
                'Employee ID *',
                'employee_id',
                _family,
                icon: Icons.badge_outlined,
                requiredField: true,
                integerField: true,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(
          'Uploaded Documents (${_documentsList.length})',
          isDark,
        ),
        const SizedBox(height: 4),

        // 1. Documents List
        if (_documentsList.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: GlassContainer(
              borderRadius: 16,
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'No documents uploaded yet.',
                  style: AppTypography.bodyMedium(isDark),
                ),
              ),
            ),
          )
        else
          for (var i = 0; i < _documentsList.length; i++) ...[
            GlassContainer(
              borderRadius: 16,
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _documentsList[i].title,
                          style: AppTypography.titleMedium(
                            isDark,
                          ).copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${_documentsList[i].category} • ${_documentsList[i].fileName} (${_documentsList[i].fileSize})',
                          style: AppTypography.caption(isDark),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Uploaded: ${_documentsList[i].uploadedDate}',
                          style: AppTypography.caption(isDark).copyWith(
                            color: isDark
                                ? Colors.white54
                                : AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Delete Document',
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    onPressed: () => _removeDocument(i),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

        const SizedBox(height: 8),

        // 2. Add Document Container Card with + Sign
        InkWell(
          onTap: () => _showAddDocumentDialog(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : AppColors.primary.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Add New Document',
                  style: AppTypography.titleMedium(isDark).copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to upload PDF, PNG or JPG files',
                  style: AppTypography.caption(isDark).copyWith(
                    color: isDark ? Colors.white54 : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
        ),
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
                _field(
                  'Institution',
                  'qualification_${i}_institution',
                  {
                    'qualification_${i}_institution':
                        qualifications[i].institution,
                  },
                  icon: Icons.account_balance_outlined,
                ),
                _yearPickerField(
                  'Year',
                  'qualification_${i}_year',
                  {'qualification_${i}_year': qualifications[i].year},
                  title: 'Select Qualification Year',
                ),
                _field(
                  'Grade / Score',
                  'qualification_${i}_grade',
                  {'qualification_${i}_grade': qualifications[i].grade},
                  icon: Icons.grade_outlined,
                ),
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
                _field(
                  'Company',
                  'experience_${i}_company',
                  {'experience_${i}_company': experiences[i].company},
                  icon: Icons.business_outlined,
                ),
                _field('Role', 'experience_${i}_role', {
                  'experience_${i}_role': experiences[i].role,
                }, icon: Icons.work_outline_rounded),
                _experiencePeriodPickerField(i, experiences[i]),
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

  Widget _activeFields(BuildContext context, bool isDark) =>
      switch (_activeTab) {
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
    final displayRole = designation.isNotEmpty
        ? designation.toLowerCase()
        : 'employee';
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
                          color: AppColors.primary,
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
    FocusManager.instance.primaryFocus?.unfocus();
    if (_activeTab == 0) {
      if (!(_formKey.currentState?.validate() ?? false)) return;
      _saveEmployeeProfile();
      return;
    }
    if (_activeTab == 5) {
      if (!(_formKey.currentState?.validate() ?? false)) return;
      _saveEmployeeFamily();
      return;
    }

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

  Future<void> _saveEmployeeProfile() async {
    final userController = Get.find<UserController>();
    await userController.updateEmployeeProfile(
      employeeName: _profileOrControllerValue('employee_name'),
      employeeCode: _profileOrControllerValue('employee_code'),
      employeeNameLocale: _profileOrControllerValue('employee_name_locale'),
      gender: _profileOrControllerValue('gender_text'),
      zoneId: _profileOrControllerValue('zone_id'),
      districtId: _profileOrControllerValue('district_id'),
      provinceId: _profileOrControllerValue('province_id'),
      municipalityId: _profileOrControllerValue('municipality_id'),
      addressPermanent: _profileOrControllerValue('address_permanent'),
      addressCurrent: _profileOrControllerValue('address_current'),
      email: _profileOrControllerValue('email'),
      emailPersonal: _profileOrControllerValue('email_per'),
      phone: _profileOrControllerValue('phone'),
      phoneSecondary: _profileOrControllerValue('phone_2'),
      dobAd: _profileOrControllerValue('dob_ad'),
      dobBs: _profileOrControllerValue('dob_bs'),
      maritalStatus: _profileOrControllerValue('marital_status_text'),
      dateJoined: _profileOrControllerValue('date_joined'),
      dateResigned: _profileOrControllerValue('date_resigned'),
    );
  }

  Future<void> _saveEmployeeFamily() async {
    final userController = Get.find<UserController>();
    await userController.updateEmployeeFamily(
      employeeId: _profileOrControllerValue('employee_id'),
      spouseName: _profileOrControllerValue('spouse_name'),
      spouseNameLocale: _profileOrControllerValue('spouse_name_locale'),
      spouseContactNum: _profileOrControllerValue('spouse_contact_num'),
      fatherName: _profileOrControllerValue('father_name'),
      fatherNameLocale: _profileOrControllerValue('father_name_locale'),
      motherName: _profileOrControllerValue('mother_name'),
      motherNameLocale: _profileOrControllerValue('mother_name_locale'),
      grandfatherName: _profileOrControllerValue('grandfather_name'),
      grandmotherName: _profileOrControllerValue('grandmother_name'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile'), centerTitle: true),
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
                Form(key: _formKey, child: _activeFields(context, isDark)),

                const SizedBox(height: 24),

                // 4. Submit / Save Button
                Obx(() {
                  if (_activeTab == 1) {
                    return const SizedBox.shrink();
                  }

                  final userController = Get.find<UserController>();
                  final isSaving = _activeTab == 5
                      ? userController.isEmployeeFamilySaving.value
                      : userController.isEmployeeProfileSaving.value;
                  return AppButton.primary(
                    label:
                        'Update ${['Personal', 'Employment', 'Documents', 'Qualifications', 'Experience', 'Family'][_activeTab]} Details',
                    icon: Icons.save_rounded,
                    isFullWidth: true,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    borderRadius: 16,
                    isLoading: isSaving,
                    onPressed: isSaving ? null : _onUpdatePressed,
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
