enum AppraisalStatus {
  draft('Draft'),
  submitted('Submitted'),
  underReview('Under Review'),
  completed('Completed');

  final String label;
  const AppraisalStatus(this.label);
}

class GoalItem {
  final String title;
  final String category;
  final double weightagePercentage; // e.g. 25%
  double selfRating; // 1 to 5
  String selfComment;

  GoalItem({
    required this.title,
    required this.category,
    required this.weightagePercentage,
    this.selfRating = 4.0,
    this.selfComment = '',
  });
}

class AppraisalRecord {
  final String id;
  final String employeeId;
  final String cycleName; // e.g., "Q3 2026 Performance Review"
  final String period;
  final List<GoalItem> goals;
  String keyAchievements;
  String areasOfImprovement;
  double overallSelfRating;
  AppraisalStatus status;
  DateTime? submittedDate;
  String? managerFeedback;
  double? managerRating;

  AppraisalRecord({
    required this.id,
    required this.employeeId,
    required this.cycleName,
    required this.period,
    required this.goals,
    required this.keyAchievements,
    required this.areasOfImprovement,
    required this.overallSelfRating,
    required this.status,
    this.submittedDate,
    this.managerFeedback,
    this.managerRating,
  });
}
