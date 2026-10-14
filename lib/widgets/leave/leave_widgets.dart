import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oms/controllers/leave_controller.dart';
import 'package:oms/models/leave_request.dart';
import 'package:oms/theme/app_colors.dart';
import 'package:oms/theme/app_typography.dart';
import 'package:oms/widgets/common/app_avatar.dart';
import 'package:oms/widgets/common/custom_buttons.dart';
import 'package:oms/widgets/common/custom_dialogs.dart';
import 'package:oms/widgets/common/ui_glass_container.dart';

// =============================================================================
// FORMATTERS
// =============================================================================

const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// "Mon, 12 Apr"
String formatLeaveShortDate(DateTime dt) =>
    '${_days[dt.weekday - 1]}, ${dt.day} ${_months[dt.month - 1]}';

/// "Mon, 12 Apr 2025"
String formatLeaveFullDate(DateTime dt) =>
    '${_days[dt.weekday - 1]}, ${dt.day} ${_months[dt.month - 1]} ${dt.year}';

/// "12 Apr 2025"
String formatLeaveDate(DateTime dt) =>
    '${dt.day} ${_months[dt.month - 1]} ${dt.year}';

/// Date line of a leave row (single day / half day vs. range).
String leaveDateText(LeaveRequest req) {
  return req.isHalfDay || req.durationDays == 1.0
      ? formatLeaveShortDate(req.startDate)
      : '${formatLeaveShortDate(req.startDate)} - '
            '${formatLeaveShortDate(req.endDate)}';
}

/// "Half Day", "1 Day", "3 Days".
String leaveDurationText(LeaveRequest req) {
  if (req.isHalfDay) return 'Half Day';
  if (req.durationDays == 1.0) return '1 Day';
  return '${req.durationDays.toInt()} Days';
}

/// 8 -> "8", 7.5 -> "7.5"
String formatDays(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

// =============================================================================
// LEAVE TYPE ICONS
// =============================================================================

extension LeaveTypeUi on LeaveType {
  IconData get icon {
    switch (this) {
      case LeaveType.annual:
        return Icons.beach_access_outlined;
      case LeaveType.sick:
        return Icons.medical_services_outlined;
      case LeaveType.casual:
        return Icons.weekend_outlined;
      case LeaveType.maternityPaternity:
        return Icons.child_care_rounded;
      case LeaveType.unpaid:
        return Icons.payments_outlined;
    }
  }
}

// =============================================================================
// SURFACES
// =============================================================================

BoxDecoration leaveCardDecoration(bool isDark, {double radius = 20}) {
  return BoxDecoration(
    color: AppColors.surface(isDark),
    borderRadius: BorderRadius.circular(radius),
    boxShadow: AppColors.softShadow(isDark),
    border: Border.all(
      color: isDark ? AppColors.borderDark : AppColors.borderSoftLight,
      width: 0.8,
    ),
  );
}

// =============================================================================
// SECTION HEADER  (title + optional "See All >" pill)
// =============================================================================

class LeaveSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const LeaveSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(title, style: AppTypography.sectionTitle(isDark)),
        ),
        if (actionLabel != null)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderSoftLight,
                  ),
                  color: AppColors.surface(isDark),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionLabel!,
                      style: AppTypography.sectionAction(
                        isDark,
                      ).copyWith(fontSize: 12),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: isDark
                          ? AppColors.primaryLight
                          : AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// =============================================================================
// STATUS PILL
// =============================================================================

class LeaveStatusPill extends StatelessWidget {
  final LeaveStatus status;

  const LeaveStatusPill({super.key, required this.status});

  IconData get _icon {
    switch (status) {
      case LeaveStatus.approved:
        return Icons.check_circle_rounded;
      case LeaveStatus.pending:
        return Icons.schedule_rounded;
      case LeaveStatus.rejected:
        return Icons.cancel_rounded;
      case LeaveStatus.cancelled:
        return Icons.block_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark
            ? status.foregroundColor.withValues(alpha: 0.2)
            : status.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 11, color: status.foregroundColor),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: status.foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// LEAVE REQUEST ROW
// =============================================================================

class LeaveRequestTile extends StatelessWidget {
  final LeaveRequest request;

  const LeaveRequestTile({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final req = request;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showLeaveDetailDialog(context, req),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Leave type icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: req.leaveType.color.withValues(
                    alpha: isDark ? 0.22 : 0.14,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  req.leaveType.icon,
                  size: 20,
                  color: req.leaveType.color,
                ),
              ),
              const SizedBox(width: 12),

              // Type, dates, reason
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      req.leaveType.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.listTitle(isDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      leaveDateText(req),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.listMeta(isDark),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.notes_rounded,
                          size: 12,
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Reason: ${req.reason}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.listMeta(
                              isDark,
                            ).copyWith(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Duration + status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    leaveDurationText(req),
                    style: AppTypography.listTitle(isDark).copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  LeaveStatusPill(status: req.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rows separated by thin, indented dividers (used inside a card).
class LeaveRequestList extends StatelessWidget {
  final List<LeaveRequest> requests;

  const LeaveRequestList({super.key, required this.requests});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        for (var i = 0; i < requests.length; i++) ...[
          LeaveRequestTile(request: requests[i]),
          if (i != requests.length - 1)
            Divider(
              height: 1,
              thickness: 1,
              indent: 70,
              endIndent: 16,
              color: AppColors.dividerSoft(isDark),
            ),
        ],
      ],
    );
  }
}

// =============================================================================
// LEAVE DETAIL DIALOG (shared by the Leave page and the Leave list)
// =============================================================================

void showLeaveDetailDialog(BuildContext context, LeaveRequest req) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  Widget row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: AppTypography.caption(
                isDark,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value, style: AppTypography.bodyMedium(isDark))),
        ],
      ),
    );
  }

  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: GlassContainer(
          borderRadius: 20,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppAvatar(
                    url: req.employeeAvatar,
                    name: req.employeeName,
                    radius: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          req.employeeName,
                          style: AppTypography.titleLarge(isDark),
                        ),
                        Text(
                          'Request Reference: ${req.id}',
                          style: AppTypography.caption(isDark),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 14),
              row('Leave Category', req.leaveType.label),
              row('Start Date (From)', formatLeaveFullDate(req.startDate)),
              row('End Date (To)', formatLeaveFullDate(req.endDate)),
              row(
                'Total Duration',
                '${req.durationDays} Day(s) ${req.isHalfDay ? "(${req.halfDayType})" : ""}',
              ),
              row('Applied On Date', formatLeaveFullDate(req.appliedOn)),
              row('Current Status', req.status.label),
              if (req.coveringEmployee != null)
                row('Handover Person', req.coveringEmployee!),
              row('Reason / Cause', req.reason),
              if (req.attachmentName != null)
                row('Attachment', req.attachmentName!),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (req.status == LeaveStatus.pending)
                    AppButton.outlined(
                      label: 'Cancel Request',
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        showDialog(
                          context: context,
                          builder: (c) => AppConfirmationDialog(
                            title: 'Cancel Leave Request?',
                            message:
                                'Cancel request ${req.id} for ${req.durationDays} day(s)?',
                            confirmLabel: 'Cancel Request',
                            isDestructive: true,
                            onConfirm: () => Get.find<LeaveController>()
                                .cancelLeaveRequest(req.id),
                          ),
                        );
                      },
                    ),
                  const SizedBox(width: 10),
                  AppButton.primary(
                    label: 'Close',
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}