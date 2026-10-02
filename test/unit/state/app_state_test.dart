import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oms/controllers/app_data_controller.dart';
import 'package:oms/models/leave_request.dart';
import 'package:oms/models/appraisal.dart';
import 'package:get/get.dart';
import 'package:oms/controllers/user_controller.dart';
import 'package:oms/controllers/app_controller.dart';
import 'package:oms/controllers/theme_controller.dart';
import 'package:oms/services/theme_service.dart';
import 'package:flutter/services.dart';

class _MemoryThemeService implements ThemeService {
  ThemeMode mode = ThemeMode.dark;

  @override
  ThemeMode loadThemeMode() => mode;

  @override
  Future<void> saveThemeMode(ThemeMode mode) async {
    this.mode = mode;
  }
}

void main() {
  group('App controller tests', () {
    late AppDataController dataController;
    late AppController appController;
    late ThemeController themeController;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      const MethodChannel(
        'plugins.flutter.io/path_provider',
      // ignore: deprecated_member_use
      ).setMockMethodCallHandler((MethodCall methodCall) async {
        return '.';
      });
      Get.put(UserController());
      appController = Get.put(AppController());
      dataController = Get.put(AppDataController());
      themeController = Get.put(
        ThemeController(themeService: _MemoryThemeService()),
      );
    });

    tearDown(() {
      Get.reset();
    });

    test('Theme toggles correctly', () {
      expect(themeController.themeMode.value, ThemeMode.dark);
      themeController.toggleTheme();
      expect(themeController.themeMode.value, ThemeMode.light);
      themeController.toggleTheme();
      expect(themeController.themeMode.value, ThemeMode.dark);
    });

    test('Page index updates correctly', () {
      expect(appController.selectedPageIndex.value, 0);
      appController.setPageIndex(2);
      expect(appController.selectedPageIndex.value, 2);
    });

    test('updateUserProfile modifies user data', () {
      dataController.updateUserProfile(
        name: 'New Name',
        designation: 'New Desig',
        department: 'IT',
        email: 'new@test.com',
        phone: '111',
        location: 'Remote',
        address: 'New Addr',
        employeeCode: '999',
        dob: '2000-01-01',
        employmentType: 'Contract',
        managerName: 'New Manager',
      );

      expect(dataController.currentUser.name, 'New Name');
      expect(dataController.currentUser.department, 'IT');
      expect(
        dataController.employees
            .firstWhere((e) => e.id == dataController.currentUser.id)
            .name,
        'New Name',
      );
    });

    test('submitLeaveRequest adds to list and updates quota', () {
      final initialLength = dataController.leaveRequests.length;
      final initialQuota = dataController.leaveQuotas
          .firstWhere((q) => q.leaveType == LeaveType.annual)
          .pendingDays;

      dataController.submitLeaveRequest(
        leaveType: LeaveType.annual,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 1)),
        durationDays: 2.0,
        isHalfDay: false,
        reason: 'Vacation',
      );

      expect(dataController.leaveRequests.length, initialLength + 1);
      final newQuota = dataController.leaveQuotas
          .firstWhere((q) => q.leaveType == LeaveType.annual)
          .pendingDays;
      expect(newQuota, initialQuota + 2.0);
    });

    test('cancelLeaveRequest updates status and restores quota', () {
      // First submit a request
      dataController.submitLeaveRequest(
        leaveType: LeaveType.sick,
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        durationDays: 1.0,
        isHalfDay: false,
        reason: 'Sick',
      );

      final req = dataController.leaveRequests.first;
      expect(req.status, LeaveStatus.pending);

      final initialQuota = dataController.leaveQuotas
          .firstWhere((q) => q.leaveType == LeaveType.sick)
          .pendingDays;

      // Now cancel it
      dataController.cancelLeaveRequest(req.id);

      final updatedReq = dataController.leaveRequests.firstWhere(
        (r) => r.id == req.id,
      );
      expect(updatedReq.status, LeaveStatus.cancelled);

      final updatedQuota = dataController.leaveQuotas
          .firstWhere((q) => q.leaveType == LeaveType.sick)
          .pendingDays;
      expect(updatedQuota, initialQuota - 1.0);
    });

    test('submitAppraisal updates appraisal status', () {
      final appraisal = AppraisalRecord(
        id: 'APR-1',
        employeeId: 'EMP-001',
        cycleName: 'Cycle',
        period: 'Q1',
        goals: [],
        keyAchievements: 'Achieved',
        areasOfImprovement: 'None',
        overallSelfRating: 5.0,
        status: AppraisalStatus.draft,
      );

      dataController.submitAppraisal(appraisal);

      expect(dataController.currentAppraisal.status, AppraisalStatus.submitted);
      expect(dataController.currentAppraisal.submittedDate, isNotNull);
    });
  });
}
