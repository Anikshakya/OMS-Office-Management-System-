import 'dart:developer';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:oms/api_config/api_repo.dart';
import 'package:oms/models/employee.dart';
import 'package:oms/services/toast_service.dart';

class UserController extends GetxController {
  final Rx<Employee?> currentUser = Rx<Employee?>(null);
  final RxMap<String, dynamic> employeeProfileData = <String, dynamic>{}.obs;
  final RxBool isEmployeeProfileLoading = false.obs;
  final RxBool isEmployeeProfileSaving = false.obs;
  final RxString employeeProfileError = ''.obs;
  final RxMap<String, dynamic> employeeFamilyData = <String, dynamic>{}.obs;
  final RxBool isEmployeeFamilyLoading = false.obs;
  final RxBool isEmployeeFamilySaving = false.obs;
  final RxString employeeFamilyError = ''.obs;
  final RxList<Map<String, dynamic>> employeeExperiences =
      <Map<String, dynamic>>[].obs;
  final RxBool isEmployeeExperiencesLoading = false.obs;
  final RxBool isEmployeeExperiencesSaving = false.obs;
  final RxString employeeExperiencesError = ''.obs;
  final box = GetStorage();

  Future<void> updateEmployeeProfile({
    required String employeeName,
    required String employeeCode,
    required String employeeNameLocale,
    required String gender,
    required String zoneId,
    required String districtId,
    required String provinceId,
    required String municipalityId,
    required String addressPermanent,
    required String addressCurrent,
    required String email,
    required String emailPersonal,
    required String phone,
    required String phoneSecondary,
    required String dobAd,
    required String dobBs,
    required String maritalStatus,
    required String dateJoined,
    required String dateResigned,
  }) async {
    if (isEmployeeProfileSaving.value) return;

    final requiredFields = <String, String>{
      'Employee name': employeeName,
      'Employee code': employeeCode,
      'Employee name (local)': employeeNameLocale,
      'Phone': phone,
      'Permanent address': addressPermanent,
      'Current address': addressCurrent,
      'Joining date': dateJoined,
    };
    final missingField = requiredFields.entries
        .where((field) => field.value.trim().isEmpty)
        .firstOrNull;
    if (missingField != null) {
      ToastService.showErrorToast('${missingField.key} is required.');
      return;
    }
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if ((email.isNotEmpty && !emailPattern.hasMatch(email.trim())) ||
        (emailPersonal.isNotEmpty &&
            !emailPattern.hasMatch(emailPersonal.trim()))) {
      ToastService.showErrorToast('Enter valid email addresses.');
      return;
    }
    if (DateTime.tryParse(dateJoined) == null) {
      ToastService.showErrorToast('Enter a valid joining date.');
      return;
    }

    final parsedZoneId = int.tryParse(zoneId);
    final parsedDistrictId = int.tryParse(districtId);
    final parsedProvinceId = int.tryParse(provinceId);
    final parsedMunicipalityId = int.tryParse(municipalityId);
    if (parsedZoneId == null ||
        parsedDistrictId == null ||
        parsedProvinceId == null ||
        parsedMunicipalityId == null) {
      ToastService.showErrorToast(
        'Zone, district, province, and municipality IDs must be valid numbers.',
      );
      return;
    }

    final genderCode = switch (gender) {
      'Male' => 'm',
      'Female' => 'f',
      'Other' => 'o',
      'Not Specified' => 'n',
      _ => '',
    };
    final maritalStatusCode = switch (maritalStatus) {
      'Unmarried' => '1',
      'Married' => '2',
      'Not Specified' => '3',
      _ => '',
    };
    if (genderCode.isEmpty || maritalStatusCode.isEmpty) {
      ToastService.showErrorToast('Select a valid gender and marital status.');
      return;
    }

    final activeValue = int.tryParse(
      employeeProfileData['active']?.toString() ?? '',
    );
    final activeText =
        employeeProfileData['active_text']?.toString().toLowerCase() ?? '';
    final active =
        activeValue ??
        (employeeProfileData['active'] == false ||
                activeText == 'no' ||
                activeText == 'inactive'
            ? 2
            : 1);
    final payload = <String, dynamic>{
      '_method': 'PATCH',
      'employee_name': employeeName,
      'employee_code': employeeCode,
      'employee_name_locale': employeeNameLocale,
      'gender': genderCode,
      'zone_id': parsedZoneId,
      'district_id': parsedDistrictId,
      'province_id': parsedProvinceId,
      'municipality_id': parsedMunicipalityId,
      'address_permanent': addressPermanent,
      'address_current': addressCurrent,
      'email': email,
      'email_per': emailPersonal,
      'phone': phone,
      'phone_2': phoneSecondary,
      'dob_ad': dobAd,
      'dob_bs': dobBs,
      'marital_status': maritalStatusCode,
      'date_joined': dateJoined,
      'date_resigned': dateResigned,
      'remarks': employeeProfileData['remarks']?.toString() ?? '',
      'active': active,
    };

    isEmployeeProfileSaving.value = true;
    try {
      final response = await ApiRepo.apiPost(
        apiPath: 'employeeapp/employees/{id}',
        data: payload,
        showToast: true,
      );
      if (response is Map && response['status'] == 'success') {
        final updatedProfile = Map<String, dynamic>.from(payload)
          ..remove('_method');
        employeeProfileData.addAll(updatedProfile);
        await fetchEmployeeProfile();
        Get.back();
      }
    } catch (error, stackTrace) {
      log('Error updating employee profile: $error', stackTrace: stackTrace);
      ToastService.showErrorToast(
        'Unable to update employee profile. Please try again.',
      );
    } finally {
      isEmployeeProfileSaving.value = false;
    }
  }

  Future<void> fetchEmployeeProfile() async {
    final user = currentUser.value;
    if (user == null) return;
    isEmployeeProfileLoading.value = true;
    employeeProfileError.value = '';
    try {
      final apiResponse = await ApiRepo.apiGet(
        apiPath: 'employeeapp/employees/{id}',
        showToast: true,
      );
      if (apiResponse != null && apiResponse['status'] == 'success') {
        final profile = Map<String, dynamic>.from(apiResponse['data'] as Map);
        employeeProfileData.assignAll(profile);
        final location =
            [profile['municipality_name'], profile['province_name']]
                .where((value) => value != null && value.toString().isNotEmpty)
                .join(', ');

        currentUser.value = user.copyWith(
          name: _profileValue(profile, 'employee_name') ?? user.name,
          designation:
              _profileValue(profile, 'current_designation_name') ??
              user.designation,
          email: _profileValue(profile, 'email') ?? user.email,
          phone: _profileValue(profile, 'phone') ?? user.phone,
          avatarUrl: _profileValue(profile, 'image_name_url') ?? '',
          status: _profileValue(profile, 'active_text') ?? user.status,
          location: location.isNotEmpty ? location : user.location,
          joinDate: _profileValue(profile, 'date_joined') ?? user.joinDate,
          managerName:
              _profileValue(profile, 'supervisor_ids_text') ?? user.managerName,
          employeeCode:
              _profileValue(profile, 'employee_code') ?? user.employeeCode,
          dob: _profileValue(profile, 'dob_ad') ?? user.dob,
          address: _profileValue(profile, 'address_permanent') ?? user.address,
        );
      }
    } catch (error, stackTrace) {
      employeeProfileError.value =
          'Unable to load employee profile. Please try again.';
      log('Error fetching employee profile: $error', stackTrace: stackTrace);
      ToastService.showErrorToast(employeeProfileError.value);
    } finally {
      isEmployeeProfileLoading.value = false;
    }
  }

  Future<void> fetchEmployeeFamily() async {
    if (currentUser.value == null) return;

    isEmployeeFamilyLoading.value = true;
    employeeFamilyError.value = '';
    try {
      final apiResponse = await ApiRepo.apiGet(
        apiPath: 'employeeapp/employee-families/{id}',
        showToast: true,
      );
      if (apiResponse is Map && apiResponse['status'] == 'success') {
        final data = apiResponse['data'];
        if (data == null) {
          employeeFamilyData.clear();
        } else if (data is Map) {
          employeeFamilyData.assignAll(Map<String, dynamic>.from(data));
        }
      }
    } catch (error, stackTrace) {
      employeeFamilyError.value =
          'Unable to load family information. Please try again.';
      log('Error fetching employee family: $error', stackTrace: stackTrace);
    } finally {
      isEmployeeFamilyLoading.value = false;
    }
  }

  Future<void> updateEmployeeFamily({
    required String employeeId,
    required String spouseName,
    required String spouseNameLocale,
    required String spouseContactNum,
    required String fatherName,
    required String fatherNameLocale,
    required String motherName,
    required String motherNameLocale,
    required String grandfatherName,
    required String grandmotherName,
    bool isCreate = false,
  }) async {
    if (isEmployeeFamilySaving.value) return;

    final parsedEmployeeId = int.tryParse(employeeId);
    if (parsedEmployeeId == null) {
      ToastService.showErrorToast('Employee ID must be a valid number.');
      return;
    }
    final requiredFields = <String, String>{
      'Father name': fatherName,
      'Father name (local)': fatherNameLocale,
      'Mother name': motherName,
      'Mother name (local)': motherNameLocale,
      'Grandfather name': grandfatherName,
      'Grandmother name': grandmotherName,
    };
    final missingField = requiredFields.entries
        .where((field) => field.value.trim().isEmpty)
        .firstOrNull;
    if (missingField != null) {
      ToastService.showErrorToast('${missingField.key} is required.');
      return;
    }

    final payload = <String, dynamic>{
      'employee_id': parsedEmployeeId,
      'spouse_name': spouseName,
      'spouse_name_locale': spouseNameLocale,
      'spouse_contact_num': spouseContactNum,
      'father_name': fatherName,
      'father_name_locale': fatherNameLocale,
      'mother_name': motherName,
      'mother_name_locale': motherNameLocale,
      'grandfather_name': grandfatherName,
      'grandmother_name': grandmotherName,
    };
    if (!isCreate) {
      payload['_method'] = 'PATCH';
    }

    isEmployeeFamilySaving.value = true;
    try {
      final response = await ApiRepo.apiPost(
        apiPath: isCreate
            ? 'employeeapp/employee-families'
            : 'employeeapp/employee-families/{id}',
        data: payload,
        showToast: true,
      );
      if (response is Map && response['status'] == 'success') {
        employeeFamilyData.addAll(payload);
        employeeFamilyData.remove('_method');
        await fetchEmployeeFamily();
        Get.back();
      }
    } catch (error, stackTrace) {
      log('Error updating employee family: $error', stackTrace: stackTrace);
      ToastService.showErrorToast(
        'Unable to update family information. Please try again.',
      );
    } finally {
      isEmployeeFamilySaving.value = false;
    }
  }

  Future<void> fetchEmployeeExperiences() async {
    if (currentUser.value == null) return;

    isEmployeeExperiencesLoading.value = true;
    employeeExperiencesError.value = '';
    try {
      final apiResponse = await ApiRepo.apiGet(
        apiPath: 'employeeapp/employee-experiences',
        showToast: true,
      );
      if (apiResponse is Map &&
          (apiResponse['success'] == true ||
              apiResponse['status'] == 'success') &&
          apiResponse['data'] is List) {
        final records = apiResponse['data'] as List;
        if (records.any((experience) => experience is! Map)) {
          throw const FormatException(
            'Employee experience response contains an invalid record.',
          );
        }
        employeeExperiences.assignAll(
          records.map((experience) => Map<String, dynamic>.from(experience)),
        );
      }
    } catch (error, stackTrace) {
      employeeExperiencesError.value =
          'Unable to load experience information. Please try again.';
      log(
        'Error fetching employee experiences: $error',
        stackTrace: stackTrace,
      );
      ToastService.showErrorToast(employeeExperiencesError.value);
    } finally {
      isEmployeeExperiencesLoading.value = false;
    }
  }

  Future<void> updateEmployeeExperience({
    required String employeeId,
    required String experienceTitle,
    required String employmentType,
    required String company,
    required String startDate,
    required String endDate,
    required String address,
    required String description,
    bool finishAfterSuccess = true,
    bool isCreate = false,
  }) async {
    if (isEmployeeExperiencesSaving.value) return;
    employeeExperiencesError.value = '';

    final parsedEmployeeId = int.tryParse(employeeId);
    final parsedEmploymentType = int.tryParse(employmentType);
    if (parsedEmployeeId == null) {
      employeeExperiencesError.value = 'Employee ID must be a valid number.';
      ToastService.showErrorToast(employeeExperiencesError.value);
      return;
    }
    if (parsedEmploymentType == null) {
      employeeExperiencesError.value = 'Select a valid employment type.';
      ToastService.showErrorToast(employeeExperiencesError.value);
      return;
    }
    if (parsedEmploymentType < 1 || parsedEmploymentType > 9) {
      employeeExperiencesError.value = 'Select a valid employment type.';
      ToastService.showErrorToast(employeeExperiencesError.value);
      return;
    }

    final requiredFields = <String, String>{
      'Experience title': experienceTitle,
      'Company': company,
      'Start date': startDate,
      'End date': endDate,
      'Address': address,
    };
    final missingField = requiredFields.entries
        .where((field) => field.value.trim().isEmpty)
        .firstOrNull;
    if (missingField != null) {
      employeeExperiencesError.value = '${missingField.key} is required.';
      ToastService.showErrorToast(employeeExperiencesError.value);
      return;
    }

    final parsedStartDate = DateTime.tryParse(startDate);
    final parsedEndDate = DateTime.tryParse(endDate);
    if (parsedStartDate == null ||
        parsedStartDate.toIso8601String().substring(0, 10) != startDate ||
        parsedEndDate == null ||
        parsedEndDate.toIso8601String().substring(0, 10) != endDate) {
      employeeExperiencesError.value = 'Enter valid start and end dates.';
      ToastService.showErrorToast(employeeExperiencesError.value);
      return;
    }

    final payload = <String, dynamic>{
      'employee_id': parsedEmployeeId,
      'experience_title': experienceTitle.trim(),
      'employment_type': parsedEmploymentType,
      'company': company.trim(),
      'start_date': startDate,
      'end_date': endDate,
      'address': address.trim(),
      'description': description.trim(),
    };
    if (!isCreate) {
      payload['_method'] = 'PATCH';
    }

    isEmployeeExperiencesSaving.value = true;
    try {
      final response = await ApiRepo.apiPost(
        apiPath: isCreate
            ? 'employeeapp/employee-experiences'
            : 'employeeapp/employee-experiences/{id}',
        data: payload,
        showToast: true,
      );
      if (response is Map &&
          (response['success'] == true || response['status'] == 'success')) {
        if (finishAfterSuccess) {
          await fetchEmployeeExperiences();
          Get.back();
        }
      } 
    } catch (error, stackTrace) {
      employeeExperiencesError.value =
          'Unable to update experience information. Please try again.';
      log('Error updating employee experience: $error', stackTrace: stackTrace);
      ToastService.showErrorToast(employeeExperiencesError.value);
    } finally {
      isEmployeeExperiencesSaving.value = false;
    }
  }

  String? _profileValue(Map<String, dynamic> profile, String key) {
    final value = profile[key]?.toString().trim();
    return value == null || value.isEmpty ? null : value;
  }

  void setCurrentUser(Employee employee) {
    var data = box.read('userData');
    if (data != null && data is Map) {
      employee = employee.copyWith(
        id: data['id']?.toString(),
        name: data['name']?.toString(),
        email: data['email']?.toString(),
        designation:
            data['role']?.toString().toUpperCase() ?? employee.designation,
        avatarUrl: data['profile_image']?.toString() ?? employee.avatarUrl,
        status: (data['active'] == 1) ? 'Active' : 'Inactive',
      );
    }
    currentUser.value = employee;
  }

  void setCurrentUserFromApi(Map<String, dynamic> userData) {
    employeeProfileData.clear();
    employeeProfileError.value = '';
    employeeFamilyData.clear();
    employeeFamilyError.value = '';
    employeeExperiences.clear();
    employeeExperiencesError.value = '';
    box.write('userData', userData);
    if (currentUser.value != null) {
      setCurrentUser(currentUser.value!);
    }
  }
}
