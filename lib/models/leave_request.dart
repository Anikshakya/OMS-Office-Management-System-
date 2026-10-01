import 'package:flutter/material.dart';

enum LeaveType {
  annual('Annual Leave', Color(0xFF0284C7)),            // Sky Blue
  sick('Sick Leave', Color.fromARGB(255, 196, 131, 190)),              // Rose Pink/Red
  casual('Casual Leave', Color(0xFFD97706)),          // Amber
  maternityPaternity('Maternity / Paternity', Color(0xFF9333EA)), // Violet
  unpaid('Unpaid Leave', Color(0xFF475569));          // Slate Blue/Gray

  final String label;
  final Color color;

  const LeaveType(this.label, this.color);
}

enum LeaveStatus {
  pending(
    'Awaiting',
    Color(0xFFFEF3C7),
    Color(0xFFD97706),
  ),
  approved(
    'Approved',
    Color(0xFFD1FAE5),
    Color(0xFF059669),
  ),
  rejected(
    'Declined',
    Color(0xFFFEE2E2),
    Color(0xFFDC2626),
  ),
  cancelled(
    'Cancelled',
    Color(0xFFF3F4F6),
    Color(0xFF6B7280),
  );

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  const LeaveStatus(this.label, this.backgroundColor, this.foregroundColor);
}

class LeaveRequest {
  final String id;
  final String employeeId;
  final String employeeName;
  final String employeeAvatar;
  final String department;
  final LeaveType leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final double durationDays;
  final bool isHalfDay;
  final String? halfDayType; // "AM" or "PM"
  final String reason;
  final String? attachmentName;
  final LeaveStatus status;
  final DateTime appliedOn;
  final String? reviewerNotes;
  final String? coveringEmployee;

  LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.employeeAvatar,
    required this.department,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.durationDays,
    this.isHalfDay = false,
    this.halfDayType,
    required this.reason,
    this.attachmentName,
    required this.status,
    required this.appliedOn,
    this.reviewerNotes,
    this.coveringEmployee,
  });

  LeaveRequest copyWith({LeaveStatus? status, String? reviewerNotes}) {
    return LeaveRequest(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      employeeAvatar: employeeAvatar,
      department: department,
      leaveType: leaveType,
      startDate: startDate,
      endDate: endDate,
      durationDays: durationDays,
      isHalfDay: isHalfDay,
      halfDayType: halfDayType,
      reason: reason,
      attachmentName: attachmentName,
      status: status ?? this.status,
      appliedOn: appliedOn,
      reviewerNotes: reviewerNotes ?? this.reviewerNotes,
      coveringEmployee: coveringEmployee,
    );
  }
}