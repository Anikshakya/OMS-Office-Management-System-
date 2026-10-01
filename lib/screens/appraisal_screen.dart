import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/common/ui_glass_container.dart';
import '../widgets/common/custom_buttons.dart';
import '../widgets/common/custom_inputs.dart';
import '../widgets/common/custom_dialogs.dart';
import '../models/appraisal.dart';

class AppraisalScreen extends StatefulWidget {
  final AppState state;

  const AppraisalScreen({super.key, required this.state});

  @override
  State<AppraisalScreen> createState() => _AppraisalScreenState();
}

class _AppraisalScreenState extends State<AppraisalScreen> {
  late AppraisalRecord _record;
  late TextEditingController _achievementsController;
  late TextEditingController _growthController;

  @override
  void initState() {
    super.initState();
    _record = widget.state.currentAppraisal;
    _achievementsController = TextEditingController(text: _record.keyAchievements);
    _growthController = TextEditingController(text: _record.areasOfImprovement);
  }

  double get _calculatedWeightedScore {
    double totalWeightedScore = 0;
    double totalWeightage = 0;

    for (var goal in _record.goals) {
      totalWeightedScore += (goal.selfRating * (goal.weightagePercentage / 100));
      totalWeightage += (goal.weightagePercentage / 100);
    }

    return totalWeightage > 0 ? (totalWeightedScore / totalWeightage) : 0.0;
  }

  void _handleSubmitAppraisal() {
    showDialog(
      context: context,
      builder: (ctx) => AppConfirmationDialog(
        title: 'Submit Performance Appraisal?',
        message: 'Your self-assessment will be submitted for review by ${widget.state.currentUser.managerName}.',
        confirmLabel: 'Submit Appraisal',
        icon: Icons.star_rate_rounded,
        iconColor: AppColors.primary,
        onConfirm: () {
          _record.keyAchievements = _achievementsController.text.trim();
          _record.areasOfImprovement = _growthController.text.trim();
          _record.overallSelfRating = _calculatedWeightedScore;
          widget.state.submitAppraisal(_record);
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.state.isDarkMode;
    final isSubmitted = _record.status == AppraisalStatus.submitted || _record.status == AppraisalStatus.completed;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cycle Banner
              GlassContainer(
                borderRadius: 16,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.stars_rounded, color: AppColors.secondary, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(_record.cycleName, style: AppTypography.titleLarge(isDark), overflow: TextOverflow.ellipsis),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isSubmitted ? AppColors.success.withValues(alpha: 0.15) : AppColors.warning.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _record.status.label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isSubmitted ? AppColors.success : AppColors.warning,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text('Review Period: ${_record.period}', style: AppTypography.bodyMedium(isDark)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Live Score Gauge
              GlassContainer(
                borderRadius: 16,
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Overall Self Rating', style: AppTypography.titleMedium(isDark)),
                          Text('Weighted score across all performance goals', style: AppTypography.caption(isDark)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.warning, size: 28),
                        const SizedBox(width: 6),
                        Text(
                          _calculatedWeightedScore.toStringAsFixed(2),
                          style: AppTypography.displayLarge(isDark).copyWith(fontSize: 26, color: AppColors.primary),
                        ),
                        Text(' / 5.0', style: AppTypography.titleMedium(isDark)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Goals List
              Text('1. Goal & Key Results Evaluation', style: AppTypography.titleLarge(isDark)),
              const SizedBox(height: 10),

              Column(
                children: _record.goals.map((goal) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GlassContainer(
                      borderRadius: 16,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(goal.title, style: AppTypography.titleMedium(isDark)),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${goal.weightagePercentage.toInt()}% Weight',
                                  style: AppTypography.caption(isDark).copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text('Rating: ${goal.selfRating.toStringAsFixed(1)}', style: AppTypography.labelLarge(isDark)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Slider(
                                  value: goal.selfRating,
                                  min: 1.0,
                                  max: 5.0,
                                  divisions: 40,
                                  activeColor: AppColors.primary,
                                  onChanged: isSubmitted
                                      ? null
                                      : (val) {
                                          setState(() => goal.selfRating = val);
                                        },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          AppTextField(
                            hint: 'Self-assessment comment for this goal...',
                            initialValue: goal.selfComment,
                            enabled: !isSubmitted,
                            onChanged: (val) => goal.selfComment = val,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Section 2 & 3: Achievements & Development
              GlassContainer(
                borderRadius: 16,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('2. Key Achievements & Highlights', style: AppTypography.titleMedium(isDark)),
                    const SizedBox(height: 6),
                    AppTextField(
                      controller: _achievementsController,
                      maxLines: 3,
                      enabled: !isSubmitted,
                      hint: 'Describe major accomplishments during this cycle...',
                    ),

                    const SizedBox(height: 16),

                    Text('3. Areas for Growth & Development', style: AppTypography.titleMedium(isDark)),
                    const SizedBox(height: 6),
                    AppTextField(
                      controller: _growthController,
                      maxLines: 3,
                      enabled: !isSubmitted,
                      hint: 'Specify skills or target areas for next cycle...',
                    ),

                    const SizedBox(height: 24),

                    if (!isSubmitted)
                      Align(
                        alignment: Alignment.centerRight,
                        child: AppButton.primary(
                          label: 'Submit Appraisal',
                          icon: Icons.send_rounded,
                          onPressed: _handleSubmitAppraisal,
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.success),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Appraisal submitted on ${_record.submittedDate?.day}/${_record.submittedDate?.month}/${_record.submittedDate?.year}.',
                                style: AppTypography.labelLarge(isDark).copyWith(color: AppColors.success),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
