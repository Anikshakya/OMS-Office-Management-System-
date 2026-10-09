import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:oms/widgets/common/custom_loading.dart';

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
import '../widgets/common/ui_glass_container.dart';

class EmployeeProfileEditScreen extends StatefulWidget {
  final int initialTab;
  final bool sectionOnly;

  const EmployeeProfileEditScreen({
    super.key,
    this.initialTab = 0,
    this.sectionOnly = false,
  });

  @override
  State<EmployeeProfileEditScreen> createState() =>
      _EmployeeProfileEditScreenState();
}

class _EmployeeProfileEditScreenState extends State<EmployeeProfileEditScreen> {
  static const _documentTypeIds = <String, int>{
    'Citizenship': 1,
    'National ID': 2,
    'Driving License': 3,
    'Voters ID': 4,
    'Passport': 5,
    'PF': 6,
    'CIT': 7,
    'SSF': 8,
    'Others': 9,
  };
  static const _employmentTypeIds = <String, int>{
    'Full time': 1,
    'Part time': 2,
    'Self employed': 3,
    'Freelance': 4,
    'Contract': 5,
    'Internship': 6,
    'Apprenticeship': 7,
    'Seasonal': 8,
    'Others': 9,
  };
  static const _degreeTypeIds = <String, int>{
    'School': 1,
    'High School': 2,
    'Bachelor': 3,
    'Master': 4,
    'MPhil': 5,
    'Training': 6,
    'Others': 7,
  };

  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  int _activeTab = 0;
  bool _isEducationFormVisible = false;
  int? _editingEducationIndex;
  bool _isExperienceFormVisible = false;
  int? _editingExperienceIndex;
  bool _isDocumentFormVisible = false;
  int? _editingDocumentIndex;
  file_picker.PlatformFile? _selectedDocumentFile;
  final GlobalKey<FormFieldState<file_picker.PlatformFile>>
  _documentFileFieldKey = GlobalKey<FormFieldState<file_picker.PlatformFile>>();

  Map<String, dynamic> get _profile {
    final controller = Get.find<UserController>();
    final profile = Map<String, dynamic>.from(controller.employeeProfileData);
    final employee = controller.currentUser.value;
    if (employee != null) {
      void addFallback(String key, String value) {
        if (profile[key]?.toString().trim().isEmpty ?? true) {
          profile[key] = value;
        }
      }

      addFallback('employee_id', employee.id);
      addFallback('employee_name', employee.name);
      addFallback('employee_code', employee.employeeCode);
      addFallback('email', employee.email);
      addFallback('phone', employee.phone);
      addFallback('address_permanent', employee.address);
      addFallback('address_current', employee.address);
      addFallback('dob_ad', employee.dob);
      addFallback('date_joined', employee.joinDate);
      addFallback('current_designation_name', employee.designation);
      addFallback('first_designation_name', employee.firstDesignation);
      addFallback('previous_designation_name', employee.prevDesignation);
      addFallback('supervisor_ids_text', employee.managerName);
      addFallback('image_name_url', employee.avatarUrl);
      addFallback('active_text', employee.status);
      addFallback('municipality_name', employee.location);
    }
    return profile;
  }

  Map<String, dynamic> get _family =>
      Get.find<UserController>().employeeFamilyData;
  bool get _hasFamilyRecord {
    final familyId = int.tryParse(_family['family_id']?.toString() ?? '');
    return _family.isNotEmpty && (familyId == null || familyId > 0);
  }

  Employee get _employee => Get.find<AppDataController>().currentUser;

  @override
  void initState() {
    super.initState();
    if (widget.initialTab >= 0 && widget.initialTab < 6) {
      _activeTab = widget.initialTab;
    }
    _loadTabData(_activeTab);
  }

  Future<void> _loadTabData(int tabIndex) async {
    final userController = Get.find<UserController>();
    switch (tabIndex) {
      case 0:
      case 1:
        await userController.fetchEmployeeProfile();
        break;
      case 2:
        await userController.fetchEmployeeDocuments();
        break;
      case 3:
        await userController.fetchEmployeeEducations();
        break;
      case 4:
        await userController.fetchEmployeeExperiences();
        break;
      case 5:
        await userController.fetchEmployeeFamily();
        break;
    }
  }

  bool _isActiveSectionLoading(UserController userController) {
    return switch (_activeTab) {
      2 => userController.isEmployeeDocumentsLoading.value,
      3 => userController.isEmployeeEducationsLoading.value,
      4 => userController.isEmployeeExperiencesLoading.value,
      _ => false,
    };
  }

  void _onTabChanged(int index) {
    setState(() => _activeTab = index);
    _loadTabData(index);
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sectionTitle = switch (_activeTab) {
      0 => 'Personal Info',
      1 => 'Employee Info',
      2 => 'Documents',
      3 => 'Qualifications',
      4 => 'Experience',
      5 => 'Family Info',
      _ => 'Edit Profile',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sectionOnly ? sectionTitle : 'Edit Profile'),
        centerTitle: true,
      ),
      body: Obx(() {
        final userController = Get.find<UserController>();
        if (_isActiveSectionLoading(userController)) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 750),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeaderCard(context),
                    const SizedBox(height: 16),
                    Expanded(child: loadingWidget()),
                  ],
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _loadTabData(_activeTab),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 750),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderCard(context),
                    const SizedBox(height: 16),
                    // 3. Tab Content Form Cards matching Apply Leave UI style
                    Obx(
                      () => Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: _activeFields(context, isDark),
                      ),
                    ),

                    const SizedBox(height: 24),

                    if (_shouldShowSaveButton)
                      Obx(() {
                        final userController = Get.find<UserController>();
                        final isSaving = switch (_activeTab) {
                          2 => userController.isEmployeeDocumentsSaving.value,
                          3 => userController.isEmployeeEducationsSaving.value,
                          4 => userController.isEmployeeExperiencesSaving.value,
                          5 => userController.isEmployeeFamilySaving.value,
                          _ => userController.isEmployeeProfileSaving.value,
                        };
                        final label = switch (_activeTab) {
                          2 =>
                            '${_editingDocumentIndex == null ? 'Add' : 'Update'} Document',
                          3 =>
                            '${_editingEducationIndex == null ? 'Add' : 'Update'} Qualification',
                          4 =>
                            '${_editingExperienceIndex == null ? 'Add' : 'Update'} Experience',
                          5 =>
                            '${_hasFamilyRecord ? 'Update' : 'Add'} Family Details',
                          _ =>
                            'Update ${['Personal', 'Employment', 'Documents', 'Qualifications', 'Experience', 'Family'][_activeTab]} Details',
                        };
                        return AppButton.primary(
                          label: label,
                          icon:
                              (_activeTab == 3 &&
                                      _editingEducationIndex == null) ||
                                  (_activeTab == 4 &&
                                      _editingExperienceIndex == null) ||
                                  (_activeTab == 2 &&
                                      _editingDocumentIndex == null) ||
                                  (_activeTab == 5 && !_hasFamilyRecord)
                              ? Icons.add_rounded
                              : Icons.save_rounded,
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
      }),
    );
  }

  String _value(Map<String, dynamic> values, String key) =>
      values[key]?.toString() ?? '';

  bool get _shouldShowSaveButton =>
      _activeTab != 1 &&
      !(_activeTab == 2 && !_isDocumentFormVisible) &&
      !(_activeTab == 3 && !_isEducationFormVisible) &&
      !(_activeTab == 4 && !_isExperienceFormVisible);

  String _employmentTypeLabel(dynamic value) {
    final id = int.tryParse(value?.toString() ?? '');
    return _employmentTypeIds.entries
        .firstWhere(
          (entry) => entry.value == id,
          orElse: () => const MapEntry('', 0),
        )
        .key;
  }

  String _degreeTypeLabel(dynamic value) {
    final id = int.tryParse(value?.toString() ?? '');
    return _degreeTypeIds.entries
        .firstWhere(
          (entry) => entry.value == id,
          orElse: () => const MapEntry('', 0),
        )
        .key;
  }

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

  Widget _field(
    String label,
    String key,
    Map<String, dynamic> values, {
    IconData? icon,
    int maxLines = 1,
    bool requiredField = false,
    bool integerField = false,
    bool emailField = false,
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
                if (emailField &&
                    value != null &&
                    value.trim().isNotEmpty &&
                    !RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    ).hasMatch(value.trim())) {
                  return 'Enter a valid email address';
                }
                return null;
              }
            : emailField
            ? (value) {
                if (value == null || value.trim().isEmpty) return null;
                return RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    ).hasMatch(value.trim())
                    ? null
                    : 'Enter a valid email address';
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
                emailField: true,
              ),
              _field(
                'Personal Email Address',
                'email_per',
                _profile,
                icon: Icons.alternate_email_rounded,
                emailField: true,
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
                isReadOnly: true,
              ),
              _field(
                'First Designation',
                'first_designation_name',
                _profile,
                icon: Icons.work_history_outlined,
                isReadOnly: true,
              ),
              _field(
                'Previous Designation',
                'previous_designation_name',
                _profile,
                icon: Icons.history_edu_rounded,
                isReadOnly: true,
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
                isReadOnly: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFamilyFields(bool isDark) {
    final userController = Get.find<UserController>();
    final familyValues = Map<String, dynamic>.from(_family)
      ..putIfAbsent(
        'employee_id',
        () => _value(_profile, 'employee_id').isNotEmpty
            ? _value(_profile, 'employee_id')
            : _employee.id,
      );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (userController.employeeFamilyError.isNotEmpty) ...[
          _emptyMessage(context, userController.employeeFamilyError.value),
          TextButton(
            onPressed: userController.isEmployeeFamilyLoading.value
                ? null
                : () => userController.fetchEmployeeFamily(),
            child: const Text('Retry'),
          ),
        ],
        _buildSectionLabel('1. Spouse Details', isDark),
        GlassContainer(
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _field(
                'Employee ID *',
                'employee_id',
                familyValues,
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
                'Father Name *',
                'father_name',
                _family,
                icon: Icons.person_outline_rounded,
                requiredField: true,
              ),
              _field(
                'Father Name (Local) *',
                'father_name_locale',
                _family,
                icon: Icons.translate_rounded,
                requiredField: true,
              ),
              _field(
                'Mother Name *',
                'mother_name',
                _family,
                icon: Icons.person_outline_rounded,
                requiredField: true,
              ),
              _field(
                'Mother Name (Local) *',
                'mother_name_locale',
                _family,
                icon: Icons.translate_rounded,
                requiredField: true,
              ),
              _field(
                'Grandfather Name *',
                'grandfather_name',
                _family,
                icon: Icons.person_outline_rounded,
                requiredField: true,
              ),
              _field(
                'Grandmother Name *',
                'grandmother_name',
                _family,
                icon: Icons.person_outline_rounded,
                requiredField: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentFields(BuildContext context, bool isDark) {
    final userController = Get.find<UserController>();
    if (_isDocumentFormVisible) {
      final document = _editingDocumentIndex == null
          ? null
          : userController.employeeDocuments[_editingDocumentIndex!];
      return _buildDocumentForm(document, isDark);
    }
    if (userController.employeeDocumentsError.isNotEmpty) {
      return Column(
        children: [
          _emptyMessage(context, userController.employeeDocumentsError.value),
          _buildAddDocumentCard(isDark),
        ],
      );
    }

    final documents = userController.employeeDocuments.asMap().entries;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (userController.employeeDocuments.isEmpty)
          _emptyMessage(context, 'No documents uploaded yet.'),
        for (final entry in documents) ...[
          _buildDocumentSummaryCard(entry.key, entry.value, isDark),
          const SizedBox(height: 12),
        ],
        _buildAddDocumentCard(isDark),
      ],
    );
  }

  Widget _buildDocumentSummaryCard(
    int index,
    Map<String, dynamic> document,
    bool isDark,
  ) {
    final title = document['doc_title']?.toString() ?? 'Document';
    final type =
        document['doc_type_text']?.toString() ??
        _documentTypeLabel(document['doc_type']);
    final fileName = document['file_name']?.toString() ?? '';
    final details = <String>[
      if (type.isNotEmpty) type,
      if (fileName.isNotEmpty) fileName,
      if (document['doc_num']?.toString().isNotEmpty ?? false)
        'No. ${document['doc_num']}',
      if (document['doc_issued_date']?.toString().isNotEmpty ?? false)
        'Issued ${document['doc_issued_date']}',
      if (document['doc_valid_date']?.toString().isNotEmpty ?? false)
        'Valid until ${document['doc_valid_date']}',
      if (document['doc_issued_place']?.toString().isNotEmpty ?? false)
        document['doc_issued_place'].toString(),
    ];
    return GlassContainer(
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
              Icons.description_outlined,
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
                  title,
                  style: AppTypography.titleMedium(
                    isDark,
                  ).copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  details.join(' • '),
                  style: AppTypography.caption(isDark),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit Document',
            onPressed: () =>
                _openDocumentForm(document: document, index: index),
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildAddDocumentCard(bool isDark) => InkWell(
    onTap: _openDocumentForm,
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
        children: [
          const Icon(
            Icons.add_circle_outline,
            color: AppColors.primary,
            size: 38,
          ),
          const SizedBox(height: 8),
          Text(
            'Add Document',
            style: AppTypography.titleMedium(
              isDark,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );

  Widget _buildDocumentForm(Map<String, dynamic>? document, bool isDark) {
    final values = <String, dynamic>{
      'document_form_doc_type':
          document?['doc_type_text']?.toString() ??
          _documentTypeLabel(document?['doc_type']),
      'document_form_doc_title': document?['doc_title'],
      'document_form_page_num': document?['page_num'],
      'document_form_doc_num': document?['doc_num'],
      'document_form_doc_issued_date': document?['doc_issued_date'],
      'document_form_doc_issued_date_locale':
          document?['doc_issued_date_locale'],
      'document_form_doc_valid_date': document?['doc_valid_date'],
      'document_form_doc_issued_place': document?['doc_issued_place'],
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(
          document == null ? 'Add Document' : 'Edit Document',
          isDark,
        ),
        GlassContainer(
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _selectionPickerField(
                'Document Type *',
                'document_form_doc_type',
                values,
                _documentTypeIds.keys.toList(),
                title: 'Select Document Type',
                icon: Icons.category_outlined,
                requiredField: true,
              ),
              _field(
                'Document Title *',
                'document_form_doc_title',
                values,
                icon: Icons.title_rounded,
                requiredField: true,
              ),
              _field(
                'Page Number *',
                'document_form_page_num',
                values,
                icon: Icons.numbers_rounded,
                requiredField: true,
                integerField: true,
              ),
              _field(
                'Document Number',
                'document_form_doc_num',
                values,
                icon: Icons.tag_rounded,
              ),
              _datePickerField(
                'Issued Date *',
                'document_form_doc_issued_date',
                values,
                title: 'Select Issued Date',
                icon: Icons.event_available_outlined,
                requiredField: true,
              ),
              _field(
                'Issued Date (Local) *',
                'document_form_doc_issued_date_locale',
                values,
                icon: Icons.translate_rounded,
                requiredField: true,
              ),
              _datePickerField(
                'Valid Date',
                'document_form_doc_valid_date',
                values,
                title: 'Select Valid Date',
                icon: Icons.event_busy_outlined,
              ),
              _field(
                'Issued Place',
                'document_form_doc_issued_place',
                values,
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 4),
              FormField<file_picker.PlatformFile>(
                key: _documentFileFieldKey,
                validator: (file) {
                  final currentDocument = document;
                  final existingFile =
                      currentDocument?['file_name']?.toString() ?? '';
                  return file != null || existingFile.isNotEmpty
                      ? null
                      : 'Choose a document file';
                },
                builder: (field) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: _pickDocumentFile,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: field.hasError
                                ? Theme.of(context).colorScheme.error
                                : AppColors.primary.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.upload_file_rounded,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedDocumentFile?.name ??
                                    document?['file_name']?.toString() ??
                                    'Select document file *',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodyMedium(isDark),
                              ),
                            ),
                            const Icon(
                              Icons.attach_file_rounded,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (field.hasError)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 6),
                        child: Text(
                          field.errorText!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppButton.outlined(label: 'Cancel', onPressed: _closeDocumentForm),
      ],
    );
  }

  Future<void> _pickDocumentFile() async {
    final file = await file_picker.FilePicker.pickFile();
    if (file == null || !mounted) return;
    setState(() => _selectedDocumentFile = file);
    _documentFileFieldKey.currentState?.didChange(file);
  }

  Widget _buildQualificationFields(BuildContext context, bool isDark) {
    final userController = Get.find<UserController>();
    if (userController.employeeEducationsError.isNotEmpty) {
      return Column(
        children: [
          _emptyMessage(context, userController.employeeEducationsError.value),
          _buildAddEducationCard(isDark),
        ],
      );
    }
    if (_isEducationFormVisible) {
      final education = _editingEducationIndex == null
          ? null
          : userController.employeeEducations[_editingEducationIndex!];
      return _buildEducationForm(education, isDark);
    }

    final educations = userController.employeeEducations.asMap().entries.where((
      entry,
    ) {
      final id = int.tryParse(entry.value['edu_id']?.toString() ?? '');
      return id == null || id > 0;
    }).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (educations.isEmpty)
          _emptyMessage(context, 'No qualifications available.'),
        for (var i = 0; i < educations.length; i++)
          _buildEducationCard(educations[i].key, educations[i].value, isDark),
        _buildAddEducationCard(isDark),
      ],
    );
  }

  Widget _buildAddEducationCard(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: InkWell(
        onTap: () => _openEducationForm(),
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
                'Add Qualification',
                style: AppTypography.titleMedium(isDark).copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap to enter a qualification',
                style: AppTypography.caption(isDark).copyWith(
                  color: isDark ? Colors.white54 : AppColors.textMutedLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEducationCard(
    int index,
    Map<String, dynamic> education,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Qualification ${index + 1}',
            style: AppTypography.labelMedium(isDark),
          ),
        ),
        GlassContainer(
          borderRadius: 16,
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.school_outlined,
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
                      education['degree_type_text']?.toString() ??
                          _degreeTypeLabel(education['degree_type']),
                      style: AppTypography.titleMedium(
                        isDark,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      education['institution']?.toString() ?? '',
                      style: AppTypography.bodyMedium(isDark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      education['specialization']?.toString() ?? '',
                      style: AppTypography.caption(isDark),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      [
                            education['start_date']?.toString(),
                            education['end_date']?.toString(),
                          ]
                          .where((date) => date != null && date.isNotEmpty)
                          .join(' – '),
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
                tooltip: 'Edit Qualification',
                onPressed: () =>
                    _openEducationForm(education: education, index: index),
                icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEducationForm(Map<String, dynamic>? education, bool isDark) {
    final values = <String, dynamic>{
      'education_form_degree_type': _degreeTypeLabel(education?['degree_type']),
      'education_form_institution': education?['institution'],
      'education_form_specialization': education?['specialization'],
      'education_form_start_date': education?['start_date'],
      'education_form_end_date': education?['end_date'],
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(
          _editingEducationIndex == null
              ? 'Add Qualification'
              : 'Edit Qualification',
          isDark,
        ),
        GlassContainer(
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _selectionPickerField(
                'Degree Type *',
                'education_form_degree_type',
                values,
                _degreeTypeIds.keys.toList(),
                title: 'Select Degree Type',
                icon: Icons.school_outlined,
                requiredField: true,
              ),
              _field(
                'Institution *',
                'education_form_institution',
                values,
                icon: Icons.account_balance_outlined,
                requiredField: true,
              ),
              _field(
                'Specialization *',
                'education_form_specialization',
                values,
                icon: Icons.menu_book_outlined,
                requiredField: true,
              ),
              _datePickerField(
                'Start Date *',
                'education_form_start_date',
                values,
                title: 'Select Education Start Date',
                icon: Icons.event_available_outlined,
                requiredField: true,
              ),
              _datePickerField(
                'End Date',
                'education_form_end_date',
                values,
                title: 'Select Education End Date',
                icon: Icons.event_busy_outlined,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppButton.outlined(label: 'Cancel', onPressed: _closeEducationForm),
      ],
    );
  }

  Widget _buildExperienceFields(BuildContext context, bool isDark) {
    final userController = Get.find<UserController>();
    if (_isExperienceFormVisible) {
      final experience = _editingExperienceIndex == null
          ? null
          : userController.employeeExperiences[_editingExperienceIndex!];
      return _buildExperienceForm(experience, isDark);
    }
    if (userController.employeeExperiencesError.isNotEmpty) {
      return Column(
        children: [
          _emptyMessage(context, userController.employeeExperiencesError.value),
          _buildAddExperienceCard(isDark),
        ],
      );
    }
    final experiences = userController.employeeExperiences
        .asMap()
        .entries
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (experiences.isEmpty)
          _emptyMessage(context, 'No experience records available.'),
        for (final entry in experiences)
          _buildExperienceSummaryCard(entry.key, entry.value, isDark),
        _buildAddExperienceCard(isDark),
      ],
    );
  }

  Widget _buildAddExperienceCard(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: InkWell(
        onTap: () => _openExperienceForm(),
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
                'Add Experience',
                style: AppTypography.titleMedium(isDark).copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap to enter an experience',
                style: AppTypography.caption(isDark).copyWith(
                  color: isDark ? Colors.white54 : AppColors.textMutedLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExperienceSummaryCard(
    int index,
    Map<String, dynamic> experience,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassContainer(
          borderRadius: 16,
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.work_outline_rounded,
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
                      experience['experience_title']?.toString() ?? '',
                      style: AppTypography.titleMedium(
                        isDark,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      experience['company']?.toString() ?? '',
                      style: AppTypography.bodyMedium(isDark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _employmentTypeLabel(experience['employment_type']),
                      style: AppTypography.caption(isDark),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      [
                            experience['start_date']?.toString(),
                            experience['end_date']?.toString(),
                          ]
                          .where((date) => date != null && date.isNotEmpty)
                          .join(' – '),
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
                tooltip: 'Edit Experience',
                onPressed: () =>
                    _openExperienceForm(experience: experience, index: index),
                icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildExperienceForm(Map<String, dynamic>? experience, bool isDark) {
    final values = <String, dynamic>{
      'experience_form_experience_title': experience?['experience_title'],
      'experience_form_employment_type': _employmentTypeLabel(
        experience?['employment_type'],
      ),
      'experience_form_company': experience?['company'],
      'experience_form_start_date': experience?['start_date'],
      'experience_form_end_date': experience?['end_date'],
      'experience_form_address': experience?['address'],
      'experience_form_description': experience?['description'],
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(
          _editingExperienceIndex == null
              ? 'Add Experience'
              : 'Edit Experience',
          isDark,
        ),
        GlassContainer(
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _field(
                'Experience Title *',
                'experience_form_experience_title',
                values,
                icon: Icons.work_outline_rounded,
                requiredField: true,
              ),
              _selectionPickerField(
                'Employment Type *',
                'experience_form_employment_type',
                values,
                _employmentTypeIds.keys.toList(),
                title: 'Select Employment Type',
                icon: Icons.category_outlined,
                requiredField: true,
              ),
              _field(
                'Company *',
                'experience_form_company',
                values,
                icon: Icons.business_outlined,
                requiredField: true,
              ),
              _datePickerField(
                'Start Date *',
                'experience_form_start_date',
                values,
                title: 'Select Experience Start Date',
                icon: Icons.event_available_outlined,
                requiredField: true,
              ),
              _datePickerField(
                'End Date *',
                'experience_form_end_date',
                values,
                title: 'Select Experience End Date',
                icon: Icons.event_busy_outlined,
                requiredField: true,
              ),
              _field(
                'Address *',
                'experience_form_address',
                values,
                icon: Icons.location_on_outlined,
                requiredField: true,
              ),
              _field(
                'Description',
                'experience_form_description',
                values,
                icon: Icons.notes_outlined,
                maxLines: 3,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppButton.outlined(label: 'Cancel', onPressed: _closeExperienceForm),
      ],
    );
  }

  Widget _emptyMessage(BuildContext context, String text) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: GlassContainer(
        borderRadius: 16,
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            text,
            style: AppTypography.bodyMedium(
              Theme.of(context).brightness == Brightness.dark,
            ),
          ),
        ),
      ),
    ),
  );

  Widget _activeFields(BuildContext context, bool isDark) {
    final section = switch (_activeTab) {
      0 => _buildPersonalFields(isDark),
      1 => _buildEmploymentFields(isDark),
      2 => _buildDocumentFields(context, isDark),
      3 => _buildQualificationFields(context, isDark),
      4 => _buildExperienceFields(context, isDark),
      5 => _buildFamilyFields(isDark),
      _ => _buildPersonalFields(isDark),
    };
    return section;
  }

  Widget _buildHeaderCard(BuildContext context) {
    final name = _value(_profile, 'employee_name');
    final displayName = name.isNotEmpty ? name.toUpperCase() : 'EMPLOYEE';

    final designation = _value(_profile, 'current_designation_name');
    final displayRole = designation.isNotEmpty ? designation : 'Employee';

    final email = _value(_profile, 'email');
    final displayEmail = email.isNotEmpty ? email : 'No email provided';

    final avatarUrl = _value(_profile, 'image_name_url');

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final background = isDark
        ? const Color(0xFF111111)
        : const Color(0xFFFFFFFF);

    final foreground = isDark ? Colors.white : const Color(0xFF151515);

    final secondary = isDark
        ? Colors.white.withValues(alpha: 0.48)
        : Colors.black.withValues(alpha: 0.45);

    final border = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.07);

    return Container(
      width: double.infinity,
      height: 190,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.08),
            blurRadius: 35,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          // =========================================================
          // BACKGROUND TYPOGRAPHIC DETAIL
          // =========================================================
          Positioned(
            right: -10,
            bottom: -32,
            child: Text(
              '01',
              style: TextStyle(
                fontSize: 170,
                fontWeight: FontWeight.w900,
                height: 1,
                color: AppColors.primary.withValues(alpha: 0.035),
                letterSpacing: -12,
              ),
            ),
          ),

          // =========================================================
          // TOP ACCENT LINE
          // =========================================================
          Positioned(
            top: 0,
            left: 28,
            right: 28,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0),
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),

          // =========================================================
          // CONTENT
          // =========================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 20, 20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 470;

                final avatarSize = compact ? 92.0 : 108.0;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // =====================================================
                    // AVATAR
                    // =====================================================
                    SizedBox(
                      width: avatarSize,
                      height: avatarSize,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Outer ring
                          Container(
                            width: avatarSize,
                            height: avatarSize,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withValues(
                                  alpha: 0.35,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: background,
                              ),
                              child: Hero(
                                tag: employeeProfileAvatarHeroTag,
                                child: AppAvatar(
                                  url: avatarUrl,
                                  name: displayName,
                                  radius: avatarSize / 2,
                                ),
                              ),
                            ),
                          ),

                          // Active status
                          Positioned(
                            right: 3,
                            bottom: 5,
                            child: Container(
                              width: 17,
                              height: 17,
                              decoration: BoxDecoration(
                                color: const Color(0xFF35C759),
                                shape: BoxShape.circle,
                                border: Border.all(color: background, width: 4),
                              ),
                            ),
                          ),

                          // Edit action
                          Positioned(
                            left: -5,
                            bottom: -3,
                            child: GestureDetector(
                              onTap: () {
                                Get.find<AppController>().showToast(
                                  'Update Avatar',
                                  'Select a photo to update your profile image.',
                                  ToastType.info,
                                );
                              },
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: background,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.20,
                                      ),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.edit_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 24),

                    // =====================================================
                    // IDENTITY
                    // =====================================================
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Eyebrow
                          Row(
                            children: [
                              Container(
                                width: 18,
                                height: 2,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'EMPLOYEE',
                                style: TextStyle(
                                  color: secondary,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2.2,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 7),

                          // Name
                          Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: foreground,
                              fontSize: compact ? 22 : 27,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.7,
                              height: 1,
                            ),
                          ),

                          const SizedBox(height: 9),

                          // Designation
                          Text(
                            displayRole,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: compact ? 12 : 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.1,
                            ),
                          ),

                          const SizedBox(height: 9),

                          // Email
                          Row(
                            children: [
                              Icon(
                                Icons.mail_outline_rounded,
                                size: 14,
                                color: secondary,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  displayEmail,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: secondary,
                                    fontSize: compact ? 11 : 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // =====================================================
                    // DESKTOP ACTION
                    // =====================================================
                    if (!compact) ...[
                      const SizedBox(width: 20),

                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.045)
                                  : Colors.black.withValues(alpha: 0.035),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: border),
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: foreground.withValues(alpha: 0.55),
                              size: 20,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'VIEW',
                            style: TextStyle(
                              color: secondary,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                );
              },
            ),
          ),

          // =========================================================
          // BOTTOM SIGNATURE
          // =========================================================
          Positioned(
            left: 24,
            right: 24,
            bottom: 0,
            child: Row(
              children: [
                Container(width: 42, height: 2, color: AppColors.primary),
                Expanded(child: Container(height: 1, color: border)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onUpdatePressed() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_activeTab == 2) {
      if (!(_formKey.currentState?.validate() ?? false)) return;
      _saveEmployeeDocument();
      return;
    }
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
    if (_activeTab == 4) {
      if (!(_formKey.currentState?.validate() ?? false)) return;
      _saveEmployeeExperiences();
      return;
    }
    if (_activeTab == 3) {
      if (!(_formKey.currentState?.validate() ?? false)) return;
      _saveEmployeeEducations();
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
      isCreate: !_hasFamilyRecord,
    );
  }

  Future<void> _saveEmployeeExperiences() async {
    final userController = Get.find<UserController>();
    final employeeId = _profileOrControllerValue('employee_id').isNotEmpty
        ? _profileOrControllerValue('employee_id')
        : _employee.id;
    final isCreate = _editingExperienceIndex == null;
    final experience = isCreate
        ? null
        : userController.employeeExperiences[_editingExperienceIndex!];

    userController.employeeExperiencesError.value = '';
    await userController.updateEmployeeExperience(
      employeeId: employeeId,
      experienceTitle: _controllerValue('experience_form_experience_title'),
      employmentType:
          _employmentTypeIds[_controllerValue(
                'experience_form_employment_type',
              )]
              ?.toString() ??
          '',
      company: _controllerValue('experience_form_company'),
      startDate: _controllerValue('experience_form_start_date'),
      endDate: _controllerValue('experience_form_end_date'),
      address: _controllerValue('experience_form_address'),
      description: _controllerValue('experience_form_description'),
      finishAfterSuccess: false,
      isCreate: isCreate,
      experienceId:
          (experience?['experience_id'] ??
                  experience?['employee_experience_id'] ??
                  experience?['id'])
              ?.toString(),
    );
    if (userController.employeeExperiencesError.isNotEmpty || !mounted) {
      return;
    }
    await userController.fetchEmployeeExperiences();
    if (!mounted) return;
    _closeExperienceForm();
  }

  Future<void> _saveEmployeeEducations() async {
    final userController = Get.find<UserController>();
    final employeeId = _profileOrControllerValue('employee_id').isNotEmpty
        ? _profileOrControllerValue('employee_id')
        : _employee.id;
    final isCreate = _editingEducationIndex == null;
    final education = isCreate
        ? null
        : userController.employeeEducations[_editingEducationIndex!];

    userController.employeeEducationsError.value = '';
    await userController.updateEmployeeEducation(
      employeeId: employeeId,
      degreeType:
          _degreeTypeIds[_controllerValue('education_form_degree_type')]
              ?.toString() ??
          '',
      institution: _controllerValue('education_form_institution'),
      specialization: _controllerValue('education_form_specialization'),
      startDate: _controllerValue('education_form_start_date'),
      endDate: _controllerValue('education_form_end_date'),
      isCreate: isCreate,
      educationId: education?['edu_id']?.toString(),
      finishAfterSuccess: false,
    );
    if (userController.employeeEducationsError.isNotEmpty || !mounted) {
      return;
    }

    await userController.fetchEmployeeEducations();
    if (!mounted) return;
    _closeEducationForm();
  }

  String _controllerValue(String key) => _controllers[key]?.text.trim() ?? '';

  void _openEducationForm({Map<String, dynamic>? education, int? index}) {
    const formFields = {
      'degree_type': 'degree_type',
      'institution': 'institution',
      'specialization': 'specialization',
      'start_date': 'start_date',
      'end_date': 'end_date',
    };
    for (final entry in formFields.entries) {
      final key = 'education_form_${entry.key}';
      final controller = _controllers.putIfAbsent(
        key,
        () => TextEditingController(),
      );
      controller.text = entry.key == 'degree_type'
          ? _degreeTypeLabel(education?[entry.value])
          : education?[entry.value]?.toString() ?? '';
    }
    setState(() {
      _editingEducationIndex = index;
      _isEducationFormVisible = true;
    });
  }

  void _closeEducationForm() {
    setState(() {
      _editingEducationIndex = null;
      _isEducationFormVisible = false;
    });
  }

  void _openExperienceForm({Map<String, dynamic>? experience, int? index}) {
    const fields = {
      'experience_title': 'experience_title',
      'employment_type': 'employment_type',
      'company': 'company',
      'start_date': 'start_date',
      'end_date': 'end_date',
      'address': 'address',
      'description': 'description',
    };
    for (final entry in fields.entries) {
      final controller = _controllers.putIfAbsent(
        'experience_form_${entry.key}',
        TextEditingController.new,
      );
      controller.text = entry.key == 'employment_type'
          ? _employmentTypeLabel(experience?[entry.value])
          : experience?[entry.value]?.toString() ?? '';
    }
    setState(() {
      _editingExperienceIndex = index;
      _isExperienceFormVisible = true;
    });
  }

  void _closeExperienceForm() {
    setState(() {
      _editingExperienceIndex = null;
      _isExperienceFormVisible = false;
    });
  }

  String _documentTypeLabel(dynamic value) {
    final id = int.tryParse(value?.toString() ?? '');
    return _documentTypeIds.entries
        .firstWhere(
          (entry) => entry.value == id,
          orElse: () => const MapEntry('', 0),
        )
        .key;
  }

  void _openDocumentForm({Map<String, dynamic>? document, int? index}) {
    const fields = {
      'doc_type': 'doc_type',
      'doc_title': 'doc_title',
      'page_num': 'page_num',
      'doc_num': 'doc_num',
      'doc_issued_date': 'doc_issued_date',
      'doc_issued_date_locale': 'doc_issued_date_locale',
      'doc_valid_date': 'doc_valid_date',
      'doc_issued_place': 'doc_issued_place',
    };
    for (final entry in fields.entries) {
      final controller = _controllers.putIfAbsent(
        'document_form_${entry.key}',
        TextEditingController.new,
      );
      controller.text = entry.key == 'doc_type'
          ? (document?['doc_type_text']?.toString() ??
                _documentTypeLabel(document?[entry.value]))
          : document?[entry.value]?.toString() ?? '';
    }
    _selectedDocumentFile = null;
    _documentFileFieldKey.currentState?.reset();
    setState(() {
      _editingDocumentIndex = index;
      _isDocumentFormVisible = true;
    });
  }

  void _closeDocumentForm() {
    setState(() {
      _editingDocumentIndex = null;
      _isDocumentFormVisible = false;
      _selectedDocumentFile = null;
    });
  }

  Future<void> _saveEmployeeDocument() async {
    final userController = Get.find<UserController>();
    final employeeId = _profileOrControllerValue('employee_id').isNotEmpty
        ? _profileOrControllerValue('employee_id')
        : _employee.id;
    final isCreate = _editingDocumentIndex == null;
    final document = isCreate
        ? null
        : userController.employeeDocuments[_editingDocumentIndex!];
    userController.employeeDocumentsError.value = '';
    await userController.saveEmployeeDocument(
      employeeId: employeeId,
      documentType:
          _documentTypeIds[_controllerValue('document_form_doc_type')]
              ?.toString() ??
          '',
      title: _controllerValue('document_form_doc_title'),
      pageNumber: _controllerValue('document_form_page_num'),
      file: _selectedDocumentFile,
      documentNumber: _controllerValue('document_form_doc_num'),
      issuedDate: _controllerValue('document_form_doc_issued_date'),
      issuedDateLocale: _controllerValue(
        'document_form_doc_issued_date_locale',
      ),
      validDate: _controllerValue('document_form_doc_valid_date'),
      issuedPlace: _controllerValue('document_form_doc_issued_place'),
      isCreate: isCreate,
      existingFileName: document?['file_name']?.toString() ?? '',
      documentId: document?['doc_id']?.toString(),
    );
    if (userController.employeeDocumentsError.isNotEmpty || !mounted) return;
    _closeDocumentForm();
  }
}
