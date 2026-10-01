import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../common/ui_glass_container.dart';
import '../common/custom_buttons.dart';
import '../common/custom_inputs.dart';

class EditProfileDialog extends StatefulWidget {
  final AppState state;

  const EditProfileDialog({super.key, required this.state});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _designationController;
  late TextEditingController _departmentController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _addressController;
  late TextEditingController _codeController;
  late TextEditingController _dobController;
  late TextEditingController _typeController;
  late TextEditingController _managerController;

  @override
  void initState() {
    super.initState();
    final user = widget.state.currentUser;
    _nameController = TextEditingController(text: user.name);
    _designationController = TextEditingController(text: user.designation);
    _departmentController = TextEditingController(text: user.department);
    _emailController = TextEditingController(text: user.email);
    _phoneController = TextEditingController(text: user.phone);
    _locationController = TextEditingController(text: user.location);
    _addressController = TextEditingController(text: user.address);
    _codeController = TextEditingController(text: user.employeeCode);
    _dobController = TextEditingController(text: user.dob);
    _typeController = TextEditingController(text: user.employmentType);
    _managerController = TextEditingController(text: user.managerName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _designationController.dispose();
    _departmentController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _codeController.dispose();
    _dobController.dispose();
    _typeController.dispose();
    _managerController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      widget.state.showToast(
        'Validation Error',
        'Name cannot be empty.',
        ToastType.error,
      );
      return;
    }

    widget.state.updateUserProfile(
      name: name,
      designation: _designationController.text.trim(),
      department: _departmentController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      location: _locationController.text.trim(),
      address: _addressController.text.trim(),
      employeeCode: _codeController.text.trim(),
      dob: _dobController.text.trim(),
      employmentType: _typeController.text.trim(),
      managerName: _managerController.text.trim(),
    );

    widget.state.showToast(
      'Profile Updated',
      'Your profile details have been saved successfully.',
      ToastType.success,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.state.isDarkMode;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 720),
        child: GlassContainer(
          borderRadius: 24,
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
                          Icons.manage_accounts_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Edit Profile Information',
                        style: AppTypography.titleLarge(isDark).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Basic Details', isDark),
                      const SizedBox(height: 8),
                      AppTextField(
                        label: 'Full Name',
                        controller: _nameController,
                        prefixIcon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 10),
                      AppTextField(
                        label: 'Job Title / Designation',
                        controller: _designationController,
                        prefixIcon: Icons.badge_outlined,
                      ),
                      const SizedBox(height: 10),
                      AppTextField(
                        label: 'Department',
                        controller: _departmentController,
                        prefixIcon: Icons.corporate_fare_outlined,
                      ),

                      const SizedBox(height: 16),
                      _buildSectionHeader('Contact & Location', isDark),
                      const SizedBox(height: 8),
                      AppTextField(
                        label: 'Work Email',
                        controller: _emailController,
                        prefixIcon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 10),
                      AppTextField(
                        label: 'Contact Phone',
                        controller: _phoneController,
                        prefixIcon: Icons.phone_outlined,
                      ),
                      const SizedBox(height: 10),
                      AppTextField(
                        label: 'Work Location',
                        controller: _locationController,
                        prefixIcon: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 10),
                      AppTextField(
                        label: 'Residential Address',
                        controller: _addressController,
                        maxLines: 2,
                      ),

                      const SizedBox(height: 16),
                      _buildSectionHeader('Employment & Identity', isDark),
                      const SizedBox(height: 8),
                      AppTextField(
                        label: 'Employee Code',
                        controller: _codeController,
                        prefixIcon: Icons.fingerprint_rounded,
                      ),
                      const SizedBox(height: 10),
                      AppTextField(
                        label: 'Date of Birth',
                        controller: _dobController,
                        prefixIcon: Icons.cake_outlined,
                      ),
                      const SizedBox(height: 10),
                      AppTextField(
                        label: 'Employment Contract Type',
                        controller: _typeController,
                        prefixIcon: Icons.description_outlined,
                      ),
                      const SizedBox(height: 10),
                      AppTextField(
                        label: 'Reporting Manager',
                        controller: _managerController,
                        prefixIcon: Icons.supervisor_account_outlined,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton.outlined(
                    label: 'Cancel',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 12),
                  AppButton.primary(
                    label: 'Save Changes',
                    icon: Icons.check_rounded,
                    onPressed: _handleSave,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: AppTypography.caption(isDark).copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
        letterSpacing: 0.5,
      ),
    );
  }
}
