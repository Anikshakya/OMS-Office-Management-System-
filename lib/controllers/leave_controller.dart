import 'dart:developer';

import 'package:get/get.dart';
import 'package:oms/api_config/api_repo.dart';
import 'package:oms/models/leave_request.dart';
import 'package:oms/controllers/user_controller.dart';

class LeaveController extends GetxController {
  final RxList<LeaveRequest> leaveHistory = <LeaveRequest>[].obs;
  final RxBool isLoading = false.obs;

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
}
