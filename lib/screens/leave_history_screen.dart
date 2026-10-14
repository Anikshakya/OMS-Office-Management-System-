import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oms/screens/leave_list.dart';

import '../controllers/app_controller.dart';
import '../controllers/app_data_controller.dart';
import '../controllers/leave_controller.dart';
import '../models/leave_quota.dart';
import '../models/leave_request.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/leave/leave_widgets.dart';

/// "Leave" tab: apply banner, leave balance and a preview of recent leaves.
/// The full history (search, year, filters) lives in [LeaveListScreen].
class LeaveHistoryScreen extends StatefulWidget {
  const LeaveHistoryScreen({super.key});

  @override
  State<LeaveHistoryScreen> createState() => _LeaveHistoryScreenState();
}

class _LeaveHistoryScreenState extends State<LeaveHistoryScreen> {
  AppDataController get _data => Get.find<AppDataController>();
  bool _showAllBalances = false;

  @override
  void initState() {
    super.initState();
    Get.find<LeaveController>().fetchLeaveHistory();
  }

  @override
  Widget build(BuildContext context) {
    final leaveController = Get.find<LeaveController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (leaveController.isLoading.value) {
        return RefreshIndicator(
          onRefresh: leaveController.fetchLeaveHistory,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      final recent = ([...leaveController.leaveHistory]
            ..sort((a, b) => b.startDate.compareTo(a.startDate)))
          .take(3)
          .toList();

      final quotas = _data.leaveQuotas;
      final visibleQuotas = _showAllBalances ? quotas : quotas.take(4).toList();

      return RefreshIndicator(
        onRefresh: leaveController.fetchLeaveHistory,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildApplyBanner(isDark),
                  const SizedBox(height: 22),

                  // Leave balance
                  LeaveSectionHeader(
                    title: 'Leave Balance',
                    actionLabel: quotas.length > 4
                        ? (_showAllBalances ? 'Show Less' : 'See All')
                        : null,
                    onAction: () =>
                        setState(() => _showAllBalances = !_showAllBalances),
                  ),
                  const SizedBox(height: 12),
                  _buildBalanceGrid(visibleQuotas, isDark),
                  const SizedBox(height: 22),

                  // Leave history preview
                  LeaveSectionHeader(
                    title: 'Leave History',
                    actionLabel: 'See All',
                    onAction: () => Get.to(() => const LeaveListScreen()),
                  ),
                  const SizedBox(height: 12),
                  _buildRecentLeaves(recent, isDark),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // "Need a Break?" banner
  // ---------------------------------------------------------------------------

  Widget _buildApplyBanner(bool isDark) {
    final tint = AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.09);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -16,
              child: Icon(
                Icons.beach_access_rounded,
                size: 120,
                color: AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.14),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Need a Break?', style: AppTypography.titleLarge(isDark)),
                  const SizedBox(height: 4),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 220),
                    child: Text(
                      'Submit your leave request in just a few clicks.',
                      style: AppTypography.bodyMedium(isDark),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Material(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                    child: InkWell(
                      onTap: () => Get.find<AppController>().setPageIndex(1),
                      borderRadius: BorderRadius.circular(24),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.add_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Apply Leave',
                              style: AppTypography.pillLabel(Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Leave balance
  // ---------------------------------------------------------------------------

  Widget _buildBalanceGrid(List<LeaveQuota> quotas, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 10.0;
        final width = (constraints.maxWidth - gap) / 2;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final q in quotas)
              SizedBox(width: width, child: _buildBalanceCard(q, isDark)),
          ],
        );
      },
    );
  }

  Widget _buildBalanceCard(LeaveQuota q, bool isDark) {
    final color = q.leaveType.color;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: leaveCardDecoration(isDark, radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.22 : 0.14),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(q.leaveType.icon, size: 15, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  q.leaveType.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.listMeta(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                formatDays(q.remainingDays),
                style: AppTypography.statValue(isDark),
              ),
              const SizedBox(width: 4),
              Text('left', style: AppTypography.listMeta(isDark)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: q.usagePercentage,
              minHeight: 5,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${formatDays(q.usedDays)} of ${formatDays(q.totalDays)} used',
            style: AppTypography.listMeta(isDark).copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Recent leaves
  // ---------------------------------------------------------------------------

  Widget _buildRecentLeaves(List<LeaveRequest> recent, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: leaveCardDecoration(isDark),
      child: recent.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              child: Center(
                child: Text(
                  'No leave requests yet.',
                  style: AppTypography.bodyMedium(isDark),
                ),
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LeaveRequestList(requests: recent),
            ),
    );
  }
}