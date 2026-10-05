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
  final RxString employeeProfileError = ''.obs;
  final RxMap<String, dynamic> employeeFamilyData = <String, dynamic>{}.obs;
  final RxBool isEmployeeFamilyLoading = false.obs;
  final RxString employeeFamilyError = ''.obs;
  final box = GetStorage();

  Future<void> fetchEmployeeProfile() async {
    final user = currentUser.value;
    if (user == null) return;
    isEmployeeProfileLoading.value = true;
    employeeProfileError.value = '';
    try {
      final apiResponse = await ApiRepo.apiGet(
        apiPath: 'employeeapp/employees/{id}',
        showToast: true
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
        showToast: true
      );
      if (apiResponse is Map &&
          apiResponse['success'] == true &&
          apiResponse['data'] is List) {
        final familyRecords = apiResponse['data'] as List;
        if (familyRecords.isEmpty) {
          employeeFamilyData.clear();
        } else if (familyRecords.first is Map) {
          employeeFamilyData.assignAll(
            Map<String, dynamic>.from(familyRecords.first as Map),
          );
        } else {
          throw const FormatException(
            'Employee family response must contain an object.',
          );
        }
      } else {
        employeeFamilyError.value = apiResponse is Map
            ? apiResponse['message']?.toString() ??
                  'Unable to load family information. Please try again.'
            : 'Unable to load family information. Please try again.';
        log('Unable to load employee family: $apiResponse');
        ToastService.showErrorToast(employeeFamilyError.value);
      }
    } catch (error, stackTrace) {
      employeeFamilyError.value =
          'Unable to load family information. Please try again.';
      log('Error fetching employee family: $error', stackTrace: stackTrace);
      ToastService.showErrorToast(employeeFamilyError.value);
    } finally {
      isEmployeeFamilyLoading.value = false;
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
    box.write('userData', userData);
    if (currentUser.value != null) {
      setCurrentUser(currentUser.value!);
    }
  }
}
