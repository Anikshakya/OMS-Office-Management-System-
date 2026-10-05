import 'package:get/get.dart';

import '../controllers/app_controller.dart';
import '../controllers/user_controller.dart';
import '../models/appraisal.dart';
import '../models/employee.dart';
import '../models/leave_quota.dart';
import '../models/leave_request.dart';
import '../models/toast_notification.dart';

class AppDataController extends GetxController {
  void showToast(String title, String message, ToastType type) =>
      Get.find<AppController>().showToast(title, message, type);

  Employee get currentUser => Get.find<UserController>().currentUser.value!;
  set currentUser(Employee val) =>
      Get.find<UserController>().setCurrentUser(val);

  late List<Employee> employees;
  late List<LeaveQuota> leaveQuotas;
  late List<LeaveRequest> leaveRequests;
  late AppraisalRecord currentAppraisal;

  // Search & Filter States
  String employeeSearchQuery = '';
  String employeeDeptFilter = 'All';
  String leaveHistorySearchQuery = '';
  String leaveHistoryStatusFilter = 'All';
  String leaveHistoryTypeFilter = 'All';

  AppDataController() {
    _initMockData();
  }

  // Edit ALL profile fields
  void updateUserProfile({
    required String name,
    required String designation,
    required String department,
    required String email,
    required String phone,
    required String location,
    required String address,
    required String employeeCode,
    required String dob,
    required String employmentType,
    required String managerName,
  }) {
    currentUser = Employee(
      id: currentUser.id,
      name: name,
      firstDesignation: currentUser.firstDesignation,
      prevDesignation: currentUser.prevDesignation,
      designation: designation,
      department: department,
      email: email,
      phone: phone,
      avatarUrl: currentUser.avatarUrl,
      status: currentUser.status,
      location: location,
      joinDate: currentUser.joinDate,
      managerName: managerName,
      employmentType: employmentType,
      employeeCode: employeeCode,
      dob: dob,
      address: address,
      documents: currentUser.documents,
      qualifications: currentUser.qualifications,
      experiences: currentUser.experiences,
    );

    final idx = employees.indexWhere((e) => e.id == currentUser.id);
    if (idx != -1) {
      employees[idx] = currentUser;
    }

    showToast(
      'Profile Updated',
      'All personal and employment details updated.',
      ToastType.success,
    );
    update();
  }

  void setCurrentUserFromApi(Map<String, dynamic> userData) {
    Get.find<UserController>().setCurrentUserFromApi(userData);

    // Also update in the mock employees list if exists
    final idx = employees.indexWhere((e) => e.id == currentUser.id);
    if (idx != -1) {
      employees[idx] = currentUser;
    } else {
      employees.insert(0, currentUser);
    }

    update();
  }

  void _initMockData() {
    // Common leave balances template for mock employees
    const defaultBalances = {
      LeaveType.annual: LeaveBalance(totalAllocated: 20, used: 8),
      LeaveType.sick: LeaveBalance(totalAllocated: 10, used: 2),
      LeaveType.casual: LeaveBalance(totalAllocated: 7, used: 3),
      LeaveType.maternityPaternity: LeaveBalance(totalAllocated: 60, used: 0),
      LeaveType.unpaid: LeaveBalance(totalAllocated: 15, used: 0),
    };

    currentUser = const Employee(
      id: 'EMP-001',
      name: 'Alex Morgan',
      firstDesignation: 'Principal Product Architect & UX Strategist',
      prevDesignation: 'Principal Product Architect & UX Strategist',
      designation: 'Principal Product Architect & UX Strategist',
      department: 'Product & Design',
      email: 'alex.morgan@corp.com',
      phone: '+1 (555) 234-5678',
      avatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=300',
      status: 'Active',
      location: 'San Francisco, CA (HQ)',
      joinDate: '15 Mar 2021',
      managerName: 'Sarah Jenkins (VP Design)',
      employmentType: 'Full-Time Executive Permanent',
      employeeCode: 'NX-9482',
      dob: '24 Aug 1992',
      address:
          '742 Evergreen Terrace, Financial District, San Francisco, CA 94107',
      leaveBalances: defaultBalances,
      documents: [
        EmployeeDocument(
          title: 'Executive Offer & Compensation Agreement',
          category: 'Contract',
          fileName: 'alex_morgan_executive_contract.pdf',
          fileSize: '3.8 MB',
          uploadedDate: '15 Mar 2021',
        ),
        EmployeeDocument(
          title: 'Global Non-Disclosure & IP Protection Policy',
          category: 'Legal',
          fileName: 'nda_ip_assignment_signed.pdf',
          fileSize: '1.9 MB',
          uploadedDate: '15 Mar 2021',
        ),
        EmployeeDocument(
          title: 'Verified International Passport ID',
          category: 'Identity',
          fileName: 'passport_scan_morgan_2026.pdf',
          fileSize: '2.1 MB',
          uploadedDate: '10 Jan 2024',
        ),
        EmployeeDocument(
          title: 'Stanford Master Degree Verification',
          category: 'Education',
          fileName: 'stanford_msc_hci_degree.pdf',
          fileSize: '4.5 MB',
          uploadedDate: '15 Mar 2021',
        ),
      ],
      qualifications: [
        Qualification(
          degree: 'M.S. in Human-Computer Interaction (HCI)',
          institution: 'Stanford University',
          year: '2018',
          grade: 'Summa Cum Laude (GPA 4.0)',
        ),
        Qualification(
          degree: 'B.S. in Computer Science & Interactive Systems',
          institution: 'Massachusetts Institute of Technology (MIT)',
          year: '2016',
          grade: 'First Class Honors',
        ),
      ],
      experiences: [
        WorkExperience(
          company: 'Apple Inc.',
          role: 'Staff Product Architect',
          period: '2021 - 2024',
          summary:
              'Architected next-generation human interface design tokens and multi-platform accessibility systems across iOS ecosystem.',
        ),
        WorkExperience(
          company: 'Figma Inc.',
          role: 'Lead UX Engineer & Design Systems Specialist',
          period: '2018 - 2021',
          summary:
              'Pioneered collaborative canvas rendering optimizations and enterprise UI design system architecture.',
        ),
      ],
    );

    employees = [
      currentUser,
      const Employee(
        id: 'EMP-002',
        name: 'Sarah Jenkins',
        firstDesignation: 'VP of Product & Design',
        prevDesignation: 'VP of Product & Design',
        designation: 'VP of Product & Design',
        department: 'Product & Design',
        email: 'sarah.jenkins@corp.com',
        phone: '+1 (555) 345-6789',
        avatarUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=300',
        status: 'On Leave',
        location: 'San Francisco, CA (HQ)',
        joinDate: '10 Jan 2020',
        managerName: 'CEO Office',
        employmentType: 'Full-Time Executive',
        employeeCode: 'NX-8102',
        dob: '12 Nov 1988',
        address: '128 Mercer St, New York, NY 10012',
        leaveBalances: defaultBalances,
        documents: [],
        qualifications: [],
        experiences: [],
      ),
      const Employee(
        id: 'EMP-003',
        name: 'Marcus Vance',
        firstDesignation: 'VP of Engineering',
        prevDesignation: 'VP of Engineering',
        designation: 'VP of Engineering',
        department: 'Engineering',
        email: 'marcus.vance@corp.com',
        phone: '+1 (555) 456-7890',
        avatarUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=300',
        status: 'On Leave',
        location: 'San Francisco, CA',
        joinDate: '01 Feb 2020',
        managerName: 'CEO Office',
        employmentType: 'Full-Time Executive',
        employeeCode: 'NX-1002',
        dob: '05 May 1985',
        address: '450 Mission St, San Francisco, CA 94105',
        leaveBalances: defaultBalances,
        documents: [],
        qualifications: [],
        experiences: [],
      ),
      const Employee(
        id: 'EMP-004',
        name: 'Sophia Patel',
        firstDesignation: 'People Operations Lead',
        prevDesignation: 'People Operations Lead',
        designation: 'People Operations Lead',
        department: 'Human Resources',
        email: 'sophia.patel@corp.com',
        phone: '+1 (555) 567-8901',
        avatarUrl:
            'https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&q=80&w=300',
        status: 'On Leave',
        location: 'Austin, TX',
        joinDate: '18 Jun 2022',
        managerName: 'HR Director',
        employmentType: 'Full-Time Permanent',
        employeeCode: 'NX-5421',
        dob: '19 Sep 1993',
        address: '201 Congress Ave, Austin, TX 78701',
        leaveBalances: defaultBalances,
        documents: [],
        qualifications: [],
        experiences: [],
      ),
      const Employee(
        id: 'EMP-005',
        name: 'Jordan Miller',
        firstDesignation: 'Senior DevOps Architect',
        prevDesignation: 'Senior DevOps Architect',
        designation: 'Senior DevOps Architect',
        department: 'Engineering',
        email: 'jordan.miller@corp.com',
        phone: '+1 (555) 678-9012',
        avatarUrl:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=300',
        status: 'On Leave',
        location: 'Seattle, WA',
        joinDate: '01 Sep 2021',
        managerName: 'Marcus Vance',
        employmentType: 'Full-Time Permanent',
        employeeCode: 'NX-6632',
        dob: '30 Mar 1989',
        address: '1200 5th Ave, Seattle, WA 98101',
        leaveBalances: defaultBalances,
        documents: [],
        qualifications: [],
        experiences: [],
      ),
      const Employee(
        id: 'EMP-006',
        name: 'Elena Rostova',
        firstDesignation: 'Lead Frontend Engineer',
        prevDesignation: 'Lead Frontend Engineer',
        designation: 'Lead Frontend Engineer',
        department: 'Engineering',
        email: 'elena.rostova@corp.com',
        phone: '+1 (555) 789-0123',
        avatarUrl:
            'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&q=80&w=300',
        status: 'On Leave',
        location: 'Boston, MA',
        joinDate: '14 Nov 2022',
        managerName: 'Marcus Vance',
        employmentType: 'Full-Time Permanent',
        employeeCode: 'NX-7721',
        dob: '18 Aug 1995',
        address: '88 Beacon St, Boston, MA 02108',
        leaveBalances: defaultBalances,
        documents: [],
        qualifications: [],
        experiences: [],
      ),
      const Employee(
        id: 'EMP-007',
        name: 'David Kim',
        firstDesignation: 'Senior Data Scientist',
        prevDesignation: 'Senior Data Scientist',
        designation: 'Senior Data Scientist',
        department: 'Engineering',
        email: 'david.kim@corp.com',
        phone: '+1 (555) 890-1234',
        avatarUrl:
            'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&q=80&w=300',
        status: 'On Leave',
        location: 'San Jose, CA',
        joinDate: '05 Apr 2023',
        managerName: 'Marcus Vance',
        employmentType: 'Full-Time Permanent',
        employeeCode: 'NX-3312',
        dob: '11 Jan 1992',
        address: '300 S 1st St, San Jose, CA 95113',
        leaveBalances: defaultBalances,
        documents: [],
        qualifications: [],
        experiences: [],
      ),
      const Employee(
        id: 'EMP-008',
        name: 'Rachel Adams',
        firstDesignation: 'Growth Marketing Lead',
        prevDesignation: 'Growth Marketing Lead',
        designation: 'Growth Marketing Lead',
        department: 'Marketing',
        email: 'rachel.adams@corp.com',
        phone: '+1 (555) 901-2345',
        avatarUrl:
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=300',
        status: 'On Leave',
        location: 'Chicago, IL',
        joinDate: '20 Jul 2022',
        managerName: 'CMO Office',
        employmentType: 'Full-Time Permanent',
        employeeCode: 'NX-4491',
        dob: '04 Oct 1994',
        address: '100 N LaSalle St, Chicago, IL 60602',
        leaveBalances: defaultBalances,
        documents: [],
        qualifications: [],
        experiences: [],
      ),
      const Employee(
        id: 'EMP-009',
        name: 'Nathaniel Cole',
        firstDesignation: 'Security Systems Lead',
        prevDesignation: 'Security Systems Lead',
        designation: 'Security Systems Lead',
        department: 'Engineering',
        email: 'nathaniel.cole@corp.com',
        phone: '+1 (555) 012-3456',
        avatarUrl:
            'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&q=80&w=300',
        status: 'On Leave',
        location: 'Denver, CO',
        joinDate: '12 Dec 2021',
        managerName: 'Marcus Vance',
        employmentType: 'Full-Time Permanent',
        employeeCode: 'NX-9011',
        dob: '22 Feb 1990',
        address: '1700 Broadway, Denver, CO 80202',
        leaveBalances: defaultBalances,
        documents: [],
        qualifications: [],
        experiences: [],
      ),
      const Employee(
        id: 'EMP-010',
        name: 'Chloe Bennett',
        firstDesignation: 'Senior Brand Specialist',
        prevDesignation: 'Senior Brand Specialist',
        designation: 'Senior Brand Specialist',
        department: 'Marketing',
        email: 'chloe.bennett@corp.com',
        phone: '+1 (555) 123-4567',
        avatarUrl:
            'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&q=80&w=300',
        status: 'On Leave',
        location: 'Los Angeles, CA',
        joinDate: '01 Aug 2023',
        managerName: 'Rachel Adams',
        employmentType: 'Full-Time Permanent',
        employeeCode: 'NX-2204',
        dob: '15 Jul 1996',
        address: '700 S Flower St, Los Angeles, CA 90017',
        leaveBalances: defaultBalances,
        documents: [],
        qualifications: [],
        experiences: [],
      ),
      const Employee(
        id: 'EMP-011',
        name: 'Victor Vance',
        firstDesignation: 'Talent Acquisition Manager',
        prevDesignation: 'Talent Acquisition Manager',
        designation: 'Talent Acquisition Manager',
        department: 'Human Resources',
        email: 'victor.vance@corp.com',
        phone: '+1 (555) 234-8901',
        avatarUrl:
            'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?auto=format&fit=crop&q=80&w=300',
        status: 'On Leave',
        location: 'Atlanta, GA',
        joinDate: '15 Nov 2022',
        managerName: 'Sophia Patel',
        employmentType: 'Full-Time Permanent',
        employeeCode: 'NX-6109',
        dob: '09 Dec 1987',
        address: '191 Peachtree St NE, Atlanta, GA 30303',
        leaveBalances: defaultBalances,
        documents: [],
        qualifications: [],
        experiences: [],
      ),
      const Employee(
        id: 'EMP-012',
        name: 'Isabella Cruz',
        firstDesignation: 'Staff Product Manager',
        prevDesignation: 'Staff Product Manager',
        designation: 'Staff Product Manager',
        department: 'Product & Design',
        email: 'isabella.cruz@corp.com',
        phone: '+1 (555) 345-9012',
        avatarUrl:
            'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?auto=format&fit=crop&q=80&w=300',
        status: 'On Leave',
        location: 'San Francisco, CA (HQ)',
        joinDate: '01 Mar 2022',
        managerName: 'Sarah Jenkins (VP Design)',
        employmentType: 'Full-Time Permanent',
        employeeCode: 'NX-4190',
        dob: '28 Jun 1991',
        address: '500 Howard St, San Francisco, CA 94105',
        leaveBalances: defaultBalances,
        documents: [],
        qualifications: [],
        experiences: [],
      ),
    ];

    leaveQuotas = [
      const LeaveQuota(
        leaveType: LeaveType.annual,
        totalDays: 20,
        usedDays: 8,
        pendingDays: 2,
      ),
      const LeaveQuota(
        leaveType: LeaveType.sick,
        totalDays: 10,
        usedDays: 2,
        pendingDays: 0,
      ),
      const LeaveQuota(
        leaveType: LeaveType.casual,
        totalDays: 7,
        usedDays: 3,
        pendingDays: 1,
      ),
      const LeaveQuota(
        leaveType: LeaveType.maternityPaternity,
        totalDays: 60,
        usedDays: 0,
        pendingDays: 0,
      ),
      const LeaveQuota(
        leaveType: LeaveType.unpaid,
        totalDays: 15,
        usedDays: 0,
        pendingDays: 0,
      ),
    ];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 10-12 Employees On Leave TODAY!
    leaveRequests = [
      LeaveRequest(
        id: 'LV-2026-012',
        employeeId: 'EMP-003',
        employeeName: 'Marcus Vance',
        employeeAvatar:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=300',
        department: 'Engineering',
        leaveType: LeaveType.sick,
        startDate: today.subtract(const Duration(days: 1)),
        endDate: today.add(const Duration(days: 2)),
        durationDays: 4.0,
        reason: 'Rest and recovery from seasonal influenza',
        status: LeaveStatus.approved,
        appliedOn: today.subtract(const Duration(days: 3)),
        coveringEmployee: 'Jordan Miller',
      ),
      LeaveRequest(
        id: 'LV-2026-011',
        employeeId: 'EMP-004',
        employeeName: 'Sophia Patel',
        employeeAvatar:
            'https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&q=80&w=300',
        department: 'Human Resources',
        leaveType: LeaveType.annual,
        startDate: today,
        endDate: today.add(const Duration(days: 4)),
        durationDays: 5.0,
        reason: 'Annual family vacation to Maui, Hawaii',
        status: LeaveStatus.approved,
        appliedOn: today.subtract(const Duration(days: 7)),
        coveringEmployee: 'Alex Morgan',
      ),
      LeaveRequest(
        id: 'LV-2026-010',
        employeeId: 'EMP-002',
        employeeName: 'Sarah Jenkins',
        employeeAvatar:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=300',
        department: 'Product & Design',
        leaveType: LeaveType.casual,
        startDate: today,
        endDate: today,
        durationDays: 0.5,
        isHalfDay: true,
        halfDayType: 'AM',
        reason: 'Car service appointment and passport renewal',
        status: LeaveStatus.approved,
        appliedOn: today.subtract(const Duration(days: 2)),
        coveringEmployee: 'Alex Morgan',
      ),
      LeaveRequest(
        id: 'LV-2026-009',
        employeeId: 'EMP-005',
        employeeName: 'Jordan Miller',
        employeeAvatar:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=300',
        department: 'Engineering',
        leaveType: LeaveType.casual,
        startDate: today,
        endDate: today.add(const Duration(days: 1)),
        durationDays: 2.0,
        reason: 'Apartment maintenance & relocation setup',
        status: LeaveStatus.approved,
        appliedOn: today.subtract(const Duration(days: 4)),
        coveringEmployee: 'Elena Rostova',
      ),
      LeaveRequest(
        id: 'LV-2026-008',
        employeeId: 'EMP-006',
        employeeName: 'Elena Rostova',
        employeeAvatar:
            'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&q=80&w=300',
        department: 'Engineering',
        leaveType: LeaveType.sick,
        startDate: today,
        endDate: today,
        durationDays: 0.25,
        isHalfDay: false,
        halfDayType: 'Quarter Day (Q1)',
        reason: 'Medical consultation & eye examination',
        status: LeaveStatus.approved,
        appliedOn: today.subtract(const Duration(days: 1)),
        coveringEmployee: 'David Kim',
      ),
      LeaveRequest(
        id: 'LV-2026-007',
        employeeId: 'EMP-007',
        employeeName: 'David Kim',
        employeeAvatar:
            'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&q=80&w=300',
        department: 'Engineering',
        leaveType: LeaveType.annual,
        startDate: today.subtract(const Duration(days: 2)),
        endDate: today.add(const Duration(days: 3)),
        durationDays: 6.0,
        reason: 'Family reunion and international flight travel',
        status: LeaveStatus.approved,
        appliedOn: today.subtract(const Duration(days: 14)),
        coveringEmployee: 'Jordan Miller',
      ),
      LeaveRequest(
        id: 'LV-2026-006',
        employeeId: 'EMP-008',
        employeeName: 'Rachel Adams',
        employeeAvatar:
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=300',
        department: 'Marketing',
        leaveType: LeaveType.casual,
        startDate: today,
        endDate: today,
        durationDays: 1.0,
        reason: 'Personal errands and banking documentation',
        status: LeaveStatus.approved,
        appliedOn: today.subtract(const Duration(days: 2)),
        coveringEmployee: 'Chloe Bennett',
      ),
      LeaveRequest(
        id: 'LV-2026-005',
        employeeId: 'EMP-009',
        employeeName: 'Nathaniel Cole',
        employeeAvatar:
            'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&q=80&w=300',
        department: 'Engineering',
        leaveType: LeaveType.sick,
        startDate: today.subtract(const Duration(days: 1)),
        endDate: today.add(const Duration(days: 1)),
        durationDays: 3.0,
        reason: 'Migraine recovery and doctor prescribed rest',
        status: LeaveStatus.approved,
        appliedOn: today.subtract(const Duration(days: 2)),
        coveringEmployee: 'David Kim',
      ),
      LeaveRequest(
        id: 'LV-2026-004',
        employeeId: 'EMP-010',
        employeeName: 'Chloe Bennett',
        employeeAvatar:
            'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&q=80&w=300',
        department: 'Marketing',
        leaveType: LeaveType.casual,
        startDate: today,
        endDate: today,
        durationDays: 0.5,
        isHalfDay: true,
        halfDayType: 'PM',
        reason: 'University guest lecture presentation',
        status: LeaveStatus.approved,
        appliedOn: today.subtract(const Duration(days: 5)),
        coveringEmployee: 'Rachel Adams',
      ),
      LeaveRequest(
        id: 'LV-2026-003',
        employeeId: 'EMP-011',
        employeeName: 'Victor Vance',
        employeeAvatar:
            'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?auto=format&fit=crop&q=80&w=300',
        department: 'Human Resources',
        leaveType: LeaveType.maternityPaternity,
        startDate: today.subtract(const Duration(days: 5)),
        endDate: today.add(const Duration(days: 10)),
        durationDays: 16.0,
        reason: 'Paternity leave for newborn child care',
        status: LeaveStatus.approved,
        appliedOn: today.subtract(const Duration(days: 20)),
        coveringEmployee: 'Sophia Patel',
      ),
      LeaveRequest(
        id: 'LV-2026-002',
        employeeId: 'EMP-012',
        employeeName: 'Isabella Cruz',
        employeeAvatar:
            'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?auto=format&fit=crop&q=80&w=300',
        department: 'Product & Design',
        leaveType: LeaveType.annual,
        startDate: today,
        endDate: today.add(const Duration(days: 2)),
        durationDays: 3.0,
        reason: 'Out-of-town architectural seminar and retreat',
        status: LeaveStatus.approved,
        appliedOn: today.subtract(const Duration(days: 10)),
        coveringEmployee: 'Alex Morgan',
      ),

      // User's own personal leave history entries (EMP-001 Alex Morgan)
      LeaveRequest(
        id: 'LV-2026-001',
        employeeId: 'EMP-001',
        employeeName: 'Alex Morgan',
        employeeAvatar:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=300',
        department: 'Product & Design',
        leaveType: LeaveType.casual,
        startDate: today.add(const Duration(days: 3)),
        endDate: today.add(const Duration(days: 5)),
        durationDays: 3.0,
        reason: 'Attending Design Systems Conference 2026',
        status: LeaveStatus.pending,
        appliedOn: today.subtract(const Duration(days: 1)),
        coveringEmployee: 'Sarah Jenkins',
      ),
      LeaveRequest(
        id: 'LV-2026-000',
        employeeId: 'EMP-001',
        employeeName: 'Alex Morgan',
        employeeAvatar:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=300',
        department: 'Product & Design',
        leaveType: LeaveType.sick,
        startDate: today.subtract(const Duration(days: 12)),
        endDate: today.subtract(const Duration(days: 12)),
        durationDays: 0.25,
        isHalfDay: false,
        halfDayType: 'Quarter Day (Q1)',
        reason: 'Morning dental checkup & cleaning',
        status: LeaveStatus.approved,
        appliedOn: today.subtract(const Duration(days: 15)),
        coveringEmployee: 'Sarah Jenkins',
      ),
    ];

    currentAppraisal = AppraisalRecord(
      id: 'APR-2026-Q3',
      employeeId: 'EMP-001',
      cycleName: 'Annual Performance Appraisal 2026',
      period: 'Q1 - Q3 2026 (Jan - Sep)',
      goals: [
        GoalItem(
          title: 'Design System 3.0 Architecture',
          category: 'Technical Excellence',
          weightagePercentage: 30,
          selfRating: 4.8,
          selfComment: 'Successfully unified component specs.',
        ),
        GoalItem(
          title: 'Cross-functional Collaboration',
          category: 'Teamwork',
          weightagePercentage: 25,
          selfRating: 4.5,
          selfComment: 'Hosted bi-weekly syncs with Engineering.',
        ),
      ],
      keyAchievements:
          'Delivered unified enterprise SaaS design system on schedule.',
      areasOfImprovement: 'Expand knowledge on automated UI testing.',
      overallSelfRating: 4.6,
      status: AppraisalStatus.draft,
    );
  }

  void submitLeaveRequest({
    required LeaveType leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required double durationDays,
    required bool isHalfDay,
    String? halfDayType,
    required String reason,
    String? attachmentName,
  }) {
    final newId =
        'LV-2026-${(leaveRequests.length + 1).toString().padLeft(3, '0')}';
    final request = LeaveRequest(
      id: newId,
      employeeId: currentUser.id,
      employeeName: currentUser.name,
      employeeAvatar: currentUser.avatarUrl,
      department: currentUser.department,
      leaveType: leaveType,
      startDate: startDate,
      endDate: endDate,
      durationDays: durationDays,
      isHalfDay: isHalfDay,
      halfDayType: halfDayType,
      reason: reason,
      attachmentName: attachmentName,
      status: LeaveStatus.pending,
      appliedOn: DateTime.now(),
    );

    leaveRequests.insert(0, request);

    final index = leaveQuotas.indexWhere((q) => q.leaveType == leaveType);
    if (index != -1) {
      final q = leaveQuotas[index];
      leaveQuotas[index] = LeaveQuota(
        leaveType: q.leaveType,
        totalDays: q.totalDays,
        usedDays: q.usedDays,
        pendingDays: q.pendingDays + durationDays,
      );
    }

    showToast(
      'Leave Applied!',
      'Request for $durationDays day(s) (${leaveType.label}) submitted.',
      ToastType.success,
    );

    update();
  }

  void cancelLeaveRequest(String id) {
    final index = leaveRequests.indexWhere((r) => r.id == id);
    if (index != -1) {
      final req = leaveRequests[index];
      if (req.status == LeaveStatus.pending) {
        leaveRequests[index] = req.copyWith(status: LeaveStatus.cancelled);

        final qIndex = leaveQuotas.indexWhere(
          (q) => q.leaveType == req.leaveType,
        );
        if (qIndex != -1) {
          final q = leaveQuotas[qIndex];
          leaveQuotas[qIndex] = LeaveQuota(
            leaveType: q.leaveType,
            totalDays: q.totalDays,
            usedDays: q.usedDays,
            pendingDays: (q.pendingDays - req.durationDays).clamp(0.0, 999.0),
          );
        }

        showToast(
          'Request Cancelled',
          'Leave request $id cancelled.',
          ToastType.info,
        );
        update();
      }
    }
  }

  void submitAppraisal(AppraisalRecord record) {
    currentAppraisal = record;
    currentAppraisal.status = AppraisalStatus.submitted;
    currentAppraisal.submittedDate = DateTime.now();

    showToast(
      'Appraisal Submitted',
      'Appraisal sent to manager.',
      ToastType.success,
    );
    update();
  }

  // Filter ONLY user's personal leave history
  List<LeaveRequest> get currentUserLeaveHistory {
    return leaveRequests.where((req) {
      final isSelf = req.employeeId == currentUser.id;
      if (!isSelf) return false;

      final matchesSearch =
          req.id.toLowerCase().contains(
            leaveHistorySearchQuery.toLowerCase(),
          ) ||
          req.reason.toLowerCase().contains(
            leaveHistorySearchQuery.toLowerCase(),
          );

      final matchesStatus =
          leaveHistoryStatusFilter == 'All' ||
          req.status.label.toLowerCase().contains(
            leaveHistoryStatusFilter.toLowerCase(),
          );

      final matchesType =
          leaveHistoryTypeFilter == 'All' ||
          req.leaveType.label.toLowerCase().contains(
            leaveHistoryTypeFilter.toLowerCase(),
          );

      return matchesSearch && matchesStatus && matchesType;
    }).toList();
  }

  List<LeaveRequest> getEmployeesOnLeaveForDate(DateTime date) {
    final target = DateTime(date.year, date.month, date.day);

    return leaveRequests.where((req) {
      if (req.status != LeaveStatus.approved) return false;
      final start = DateTime(
        req.startDate.year,
        req.startDate.month,
        req.startDate.day,
      );
      final end = DateTime(
        req.endDate.year,
        req.endDate.month,
        req.endDate.day,
      );
      return (target.isAfter(start.subtract(const Duration(days: 1))) &&
          target.isBefore(end.add(const Duration(days: 1))));
    }).toList();
  }

  List<LeaveRequest> get employeesOnLeaveToday =>
      getEmployeesOnLeaveForDate(DateTime.now());

  List<Employee> get filteredEmployees {
    return employees.where((emp) {
      final matchesSearch =
          emp.name.toLowerCase().contains(employeeSearchQuery.toLowerCase()) ||
          emp.designation.toLowerCase().contains(
            employeeSearchQuery.toLowerCase(),
          ) ||
          emp.email.toLowerCase().contains(employeeSearchQuery.toLowerCase());
      final matchesDept =
          employeeDeptFilter == 'All' || emp.department == employeeDeptFilter;
      return matchesSearch && matchesDept;
    }).toList();
  }
}
