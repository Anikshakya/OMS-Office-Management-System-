import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oms/state/app_state.dart';
import 'package:oms/models/leave_request.dart';
import 'package:oms/models/appraisal.dart';

void main() {
  group('AppState Tests', () {
    late AppState appState;

    setUp(() {
      appState = AppState();
    });

    test('Theme toggles correctly', () {
      expect(appState.themeMode, ThemeMode.dark);
      appState.toggleTheme();
      expect(appState.themeMode, ThemeMode.light);
      appState.toggleTheme();
      expect(appState.themeMode, ThemeMode.dark);
    });

    test('Page index updates correctly', () {
      expect(appState.selectedPageIndex, 0);
      appState.setPageIndex(2);
      expect(appState.selectedPageIndex, 2);
    });

    test('updateUserProfile modifies user data', () {
      appState.updateUserProfile(
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

      expect(appState.currentUser.name, 'New Name');
      expect(appState.currentUser.department, 'IT');
      expect(appState.employees.firstWhere((e) => e.id == appState.currentUser.id).name, 'New Name');
    });

    test('submitLeaveRequest adds to list and updates quota', () {
      final initialLength = appState.leaveRequests.length;
      final initialQuota = appState.leaveQuotas.firstWhere((q) => q.leaveType == LeaveType.annual).pendingDays;

      appState.submitLeaveRequest(
        leaveType: LeaveType.annual,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 1)),
        durationDays: 2.0,
        isHalfDay: false,
        reason: 'Vacation',
      );

      expect(appState.leaveRequests.length, initialLength + 1);
      final newQuota = appState.leaveQuotas.firstWhere((q) => q.leaveType == LeaveType.annual).pendingDays;
      expect(newQuota, initialQuota + 2.0);
    });

    test('cancelLeaveRequest updates status and restores quota', () {
      // First submit a request
      appState.submitLeaveRequest(
        leaveType: LeaveType.sick,
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        durationDays: 1.0,
        isHalfDay: false,
        reason: 'Sick',
      );

      final req = appState.leaveRequests.first;
      expect(req.status, LeaveStatus.pending);
      
      final initialQuota = appState.leaveQuotas.firstWhere((q) => q.leaveType == LeaveType.sick).pendingDays;

      // Now cancel it
      appState.cancelLeaveRequest(req.id);

      final updatedReq = appState.leaveRequests.firstWhere((r) => r.id == req.id);
      expect(updatedReq.status, LeaveStatus.cancelled);

      final updatedQuota = appState.leaveQuotas.firstWhere((q) => q.leaveType == LeaveType.sick).pendingDays;
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

      appState.submitAppraisal(appraisal);

      expect(appState.currentAppraisal.status, AppraisalStatus.submitted);
      expect(appState.currentAppraisal.submittedDate, isNotNull);
    });
  });
}
