import 'package:oms/models/leave_request.dart';

class EmployeeDocument {
  final String title;
  final String category; // e.g. "Identity", "Contract", "Tax", "Degree"
  final String fileName;
  final String fileSize;
  final String uploadedDate;

  const EmployeeDocument({
    required this.title,
    required this.category,
    required this.fileName,
    required this.fileSize,
    required this.uploadedDate,
  });
}

class Qualification {
  final String degree;
  final String institution;
  final String year;
  final String grade;

  const Qualification({
    required this.degree,
    required this.institution,
    required this.year,
    required this.grade,
  });
}

class WorkExperience {
  final String company;
  final String role;
  final String period;
  final String summary;

  const WorkExperience({
    required this.company,
    required this.role,
    required this.period,
    required this.summary,
  });
}

class LeaveBalance {
  final double totalAllocated;
  final double used;

  const LeaveBalance({
    required this.totalAllocated,
    required this.used,
  });

  /// Dynamically calculates remaining leave balance
  double get remaining => totalAllocated - used;

  /// Creates a copy of [LeaveBalance] with updated fields
  LeaveBalance copyWith({
    double? totalAllocated,
    double? used,
  }) {
    return LeaveBalance(
      totalAllocated: totalAllocated ?? this.totalAllocated,
      used: used ?? this.used,
    );
  }
}

class Employee {
  final String id;
  final String name;
  final String designation;
  final String department;
  final String email;
  final String phone;
  final String avatarUrl;
  final String status; // "Active", "On Leave", "Remote", "Terminated"
  final String location;
  final String joinDate;
  final String managerName;
  final String employmentType; // "Full-Time", "Contract", "Part-Time"
  final String employeeCode;
  final String dob;
  final String address;
  final List<EmployeeDocument> documents;
  final List<Qualification> qualifications;
  final List<WorkExperience> experiences;

  /// Map holding leave balances for each LeaveType
  final Map<LeaveType, LeaveBalance> leaveBalances;

  const Employee({
    required this.id,
    required this.name,
    required this.designation,
    required this.department,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.status,
    required this.location,
    required this.joinDate,
    required this.managerName,
    required this.employmentType,
    required this.employeeCode,
    required this.dob,
    required this.address,
    required this.documents,
    required this.qualifications,
    required this.experiences,
    this.leaveBalances = const {},
  });

  /// Helper to get balance for a specific leave type safely
  LeaveBalance getBalance(LeaveType type) {
    return leaveBalances[type] ?? const LeaveBalance(totalAllocated: 0, used: 0);
  }

  /// Returns a new [Employee] instance with updated leave balances
  Employee copyWith({
    String? id,
    String? name,
    String? designation,
    String? department,
    String? email,
    String? phone,
    String? avatarUrl,
    String? status,
    String? location,
    String? joinDate,
    String? managerName,
    String? employmentType,
    String? employeeCode,
    String? dob,
    String? address,
    List<EmployeeDocument>? documents,
    List<Qualification>? qualifications,
    List<WorkExperience>? experiences,
    Map<LeaveType, LeaveBalance>? leaveBalances,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      designation: designation ?? this.designation,
      department: department ?? this.department,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
      location: location ?? this.location,
      joinDate: joinDate ?? this.joinDate,
      managerName: managerName ?? this.managerName,
      employmentType: employmentType ?? this.employmentType,
      employeeCode: employeeCode ?? this.employeeCode,
      dob: dob ?? this.dob,
      address: address ?? this.address,
      documents: documents ?? this.documents,
      qualifications: qualifications ?? this.qualifications,
      experiences: experiences ?? this.experiences,
      leaveBalances: leaveBalances ?? this.leaveBalances,
    );
  }

  /// Deducts days when a leave request is submitted or approved
  Employee deductLeave(LeaveType type, double days) {
    final currentBalance = getBalance(type);
    final updatedMap = Map<LeaveType, LeaveBalance>.from(leaveBalances);

    updatedMap[type] = currentBalance.copyWith(
      used: currentBalance.used + days,
    );

    return copyWith(leaveBalances: updatedMap);
  }
}
