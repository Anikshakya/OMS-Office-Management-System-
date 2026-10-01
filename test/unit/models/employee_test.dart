import 'package:flutter_test/flutter_test.dart';
import 'package:oms/models/employee.dart';
import 'package:oms/models/leave_request.dart';

void main() {
  group('Employee Model Tests', () {
    test('LeaveBalance copyWith updates fields correctly', () {
      const balance = LeaveBalance(totalAllocated: 20, used: 5);
      final updated = balance.copyWith(used: 10);
      
      expect(updated.totalAllocated, 20);
      expect(updated.used, 10);
      expect(updated.remaining, 10);
    });

    test('Employee deductLeave updates leave balance correctly', () {
      final employee = Employee(
        id: '1',
        name: 'Test',
        designation: 'Dev',
        department: 'IT',
        email: 'test@test.com',
        phone: '123',
        avatarUrl: '',
        status: 'Active',
        location: 'HQ',
        joinDate: '2022',
        managerName: 'Manager',
        employmentType: 'Full-time',
        employeeCode: '001',
        dob: '2000',
        address: 'Addr',
        documents: [],
        qualifications: [],
        experiences: [],
        leaveBalances: {
          LeaveType.annual: const LeaveBalance(totalAllocated: 20, used: 5),
        },
      );

      final updated = employee.deductLeave(LeaveType.annual, 2);
      
      expect(updated.getBalance(LeaveType.annual).used, 7);
      expect(updated.getBalance(LeaveType.annual).remaining, 13);
    });
  });
}
