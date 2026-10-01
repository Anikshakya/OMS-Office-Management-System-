import 'leave_request.dart';

class LeaveQuota {
  final LeaveType leaveType;
  final double totalDays;
  final double usedDays;
  final double pendingDays;

  const LeaveQuota({
    required this.leaveType,
    required this.totalDays,
    required this.usedDays,
    required this.pendingDays,
  });

  double get remainingDays => totalDays - usedDays - pendingDays;
  double get usagePercentage => totalDays > 0 ? (usedDays / totalDays).clamp(0.0, 1.0) : 0.0;
}
