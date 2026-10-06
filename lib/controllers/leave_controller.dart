import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:oms/api_config/api_repo.dart';
import 'package:oms/models/leave_request.dart';
import 'package:oms/controllers/user_controller.dart';
import 'package:oms/services/toast_service.dart';

class LeaveController extends GetxController {
  final RxList<LeaveRequest> leaveHistory = <LeaveRequest>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isApplyLeaveLoading = false.obs;

  Future<void> fetchLeaveHistory() async {
    final user = Get.find<UserController>().currentUser.value;
    if (user == null) return;
    isLoading.value = true;
    try {
      final apiResponse = await ApiRepo.apiGet(
        apiPath: "employeeapp/employee-leaves",
      );

      if (apiResponse != null && apiResponse['status'] == "success" && apiResponse['data'] != null) { 
        final List<dynamic> data = apiResponse['data'];
        final List<LeaveRequest> fetchedLeaves = data.map((json) {
          return _mapJsonToLeaveRequest(
            json,
            user.name,
            user.avatarUrl,
            user.department,
          );
        }).toList();
        leaveHistory.assignAll(fetchedLeaves);
      }
    } catch (e) {
      log("Error fetching leave history: $e");
    } finally {
      isLoading.value = false;
    }
  }

  LeaveRequest _mapJsonToLeaveRequest(
    Map<String, dynamic> json,
    String empName,
    String empAvatar,
    String empDept,
  ) {
    LeaveType type;
    switch (json['leave_id']) {
      case 1:
        type = LeaveType.annual;
        break;
      case 2:
        type = LeaveType.sick;
        break;
      case 3:
        type = LeaveType.casual;
        break;
      case 4:
        type = LeaveType.maternityPaternity;
        break;
      default:
        type = LeaveType.annual;
    }

    LeaveStatus status;
    switch (json['leave_status']) {
      case 0:
        status = LeaveStatus.pending;
        break;
      case 1:
        status = LeaveStatus.approved;
        break;
      case 2:
        status = LeaveStatus.rejected;
        break;
      default:
        status = LeaveStatus.pending;
    }

    return LeaveRequest(
      id: json['employee_leave_id']?.toString() ?? 'Unknown',
      employeeId: json['employee_id']?.toString() ?? 'Unknown',
      employeeName: empName,
      employeeAvatar: empAvatar,
      department: empDept,
      leaveType: type,
      startDate: DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] ?? '') ?? DateTime.now(),
      durationDays:
          double.tryParse(json['total_days']?.toString() ?? '0') ?? 0.0,
      isHalfDay: json['leave_duration_type'] == 1,
      reason: json['leave_reason'] ?? '',
      status: status,
      appliedOn: DateTime.tryParse(json['applied_at'] ?? '') ?? DateTime.now(),
      reviewerNotes: json['hr_remarks'] ?? json['supervisor_remarks'],
      coveringEmployee: json['supervisor_id_cc']?.toString(),
    );
  }

  void cancelLeaveRequest(String id) {
    final index = leaveHistory.indexWhere((r) => r.id == id);
    if (index != -1) {
      final updatedReq = leaveHistory[index].copyWith(
        status: LeaveStatus.cancelled,
      );
      leaveHistory[index] = updatedReq;
    }
  }

  // Apply Leave
  Future<bool> applyLeave({
    required String supervisorId,
    required String coveringEmployee,
    required DateTime startDate,
    required DateTime endDate,
    required int leaveId,
    required String leaveDurationType,
    required String leaveReason,
    required int employeeId,
  }) async {
    final parsedSupervisorId = int.tryParse(supervisorId.trim());
    final parsedLeaveDurationType = int.tryParse(leaveDurationType.trim());
    if (parsedSupervisorId == null ||
        parsedSupervisorId <= 0 ||
        parsedLeaveDurationType == null) {
      ToastService.showErrorToast(
        'Please select a valid supervisor and leave duration.',
      );
      return false;
    }

    isApplyLeaveLoading.value = true;
    try {
      final dateFormat = DateFormat('yyyy-MM-dd');
      final formattedStartDate = dateFormat.format(startDate);
      final formattedEndDate = dateFormat.format(endDate);
      final data = {
        'fiscal_year_id': 4,
        'employee_id': employeeId,
        'leave_id': leaveId,
        'leave_duration_type': parsedLeaveDurationType,
        'start_date': formattedStartDate,
        'end_date': formattedEndDate,
        'start_date_locale': formattedStartDate,
        'end_date_locale': formattedEndDate,
        'leave_reason': leaveReason.trim(),
        'supervisor_id': parsedSupervisorId,
        // 'supervisor_id_cc': coveringEmployee.trim().isEmpty
        //     ? null
        //     : coveringEmployee.trim(),
      };
      final apiResponse = await ApiRepo.apiPost(
        apiPath: 'employeeapp/employee-leaves/apply',
        options: Options(
          headers: {'x-fiscal-year-id': '4'},
        ),
        data: data,
        showToast: false,
      );

      if (apiResponse is Map && apiResponse['status'] == 'success') {
        unawaited(fetchLeaveHistory());
        Get.back();
        ToastService.showSuccessToast(
          apiResponse['message']?.toString() ??
              'Leave request submitted successfully.',
        );
        return true;
      } else {
        final message = apiResponse is Map
            ? apiResponse['message']?.toString()
            : apiResponse?.toString();
        ToastService.showErrorToast(
          message == null || message.isEmpty
              ? 'Unable to submit leave request. Please try again.'
              : message,
        );
        return false;
      }
    } catch (error, stackTrace) {
      log('Error applying for leave: $error', stackTrace: stackTrace);
      ToastService.showErrorToast(
        'Unable to submit leave request. Please try again.',
      );
      return false;
    } finally {
      isApplyLeaveLoading.value = false;
    }
  }
}
