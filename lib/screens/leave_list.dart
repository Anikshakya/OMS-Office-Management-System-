import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/app_data_controller.dart';
import '../controllers/leave_controller.dart';
import '../models/leave_request.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/common/custom_cupertino_date_picker.dart';
import '../widgets/common/custom_inputs.dart';
import '../widgets/leave/leave_widgets.dart';

/// Full leave history: search, year selector and a filter sheet
/// (leave type, date range, status).
class LeaveListScreen extends StatefulWidget {
  const LeaveListScreen({super.key});

  @override
  State<LeaveListScreen> createState() => _LeaveListScreenState();
}

class _LeaveListScreenState extends State<LeaveListScreen> {
  AppDataController get _data => Get.find<AppDataController>();

  // Applied filters
  String _statusFilter = 'All'; // All | Pending | Approved | Rejected
  LeaveType? _typeFilter; // null = all types
  DateTime? _startDate;
  DateTime? _endDate;
  int _selectedYear = DateTime.now().year;

  late final TextEditingController _searchController;

  static const _statusOptions = ['All', 'Pending', 'Approved', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: _data.leaveHistorySearchQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasDateFilter => _startDate != null || _endDate != null;

  int get _activeFilterCount =>
      (_statusFilter != 'All' ? 1 : 0) +
      (_typeFilter != null ? 1 : 0) +
      (_hasDateFilter ? 1 : 0);

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  List<LeaveRequest> _applyFilters(List<LeaveRequest> history) {
    final query = _data.leaveHistorySearchQuery.trim().toLowerCase();

    return history.where((req) {
      // A custom date range replaces the year selector.
      final matchesYear = _hasDateFilter || req.startDate.year == _selectedYear;

      final matchesSearch =
          query.isEmpty ||
          req.id.toLowerCase().contains(query) ||
          req.reason.toLowerCase().contains(query);

      final matchesType = _typeFilter == null || req.leaveType == _typeFilter;

      final matchesStatus = switch (_statusFilter) {
        'Pending' => req.status == LeaveStatus.pending,
        'Approved' => req.status == LeaveStatus.approved,
        'Rejected' => req.status == LeaveStatus.rejected,
        _ => true,
      };

      var matchesDate = true;
      if (_startDate != null) {
        matchesDate =
            matchesDate && !_dateOnly(req.endDate).isBefore(_startDate!);
      }
      if (_endDate != null) {
        matchesDate =
            matchesDate && !_dateOnly(req.startDate).isAfter(_endDate!);
      }

      return matchesYear &&
          matchesSearch &&
          matchesType &&
          matchesStatus &&
          matchesDate;
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final leaveController = Get.find<LeaveController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Text('Leave History', style: AppTypography.sectionTitle(isDark)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildFilterButton(isDark),
          ),
        ],
      ),
      body: Obx(() {
        if (leaveController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.primary,
            ),
          );
        }

        final myHistory = leaveController.leaveHistory;

        // Years available from the request history
        final currentYear = DateTime.now().year;
        final availableYears =
            myHistory.map((e) => e.startDate.year).toSet().toList()
              ..sort((a, b) => b.compareTo(a));
        if (!availableYears.contains(currentYear)) {
          availableYears.add(currentYear);
          availableYears.sort((a, b) => b.compareTo(a));
        }

        final filtered = _applyFilters(myHistory);

        return RefreshIndicator(
          onRefresh: leaveController.fetchLeaveHistory,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search + year selector
                      Row(
                        children: [
                          Expanded(
                            child: AppSearchField(
                              controller: _searchController,
                              hint: 'Search by ID or reason...',
                              onChanged: (val) {
                                setState(
                                  () => _data.leaveHistorySearchQuery = val,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          _buildYearSelector(availableYears, isDark),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Section label + result count
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _hasDateFilter
                                  ? 'Filtered leaves'
                                  : 'Leaves in $_selectedYear',
                              style: AppTypography.listMeta(
                                isDark,
                              ).copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${filtered.length} '
                              '${filtered.length == 1 ? 'result' : 'results'}',
                              style: AppTypography.listMeta(isDark),
                            ),
                          ],
                        ),
                      ),

                      _buildList(filtered, isDark),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildList(List<LeaveRequest> filtered, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: leaveCardDecoration(isDark),
      child: filtered.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
              child: Column(
                children: [
                  Icon(
                    Icons.event_busy_rounded,
                    size: 28,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _hasDateFilter
                        ? 'No leaves matching filters.'
                        : 'No leaves matching filters for $_selectedYear.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium(isDark),
                  ),
                ],
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LeaveRequestList(requests: filtered),
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header controls
  // ---------------------------------------------------------------------------

  Widget _buildFilterButton(bool isDark) {
    final count = _activeFilterCount;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: AppColors.surface(isDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderSoftLight,
            ),
          ),
          child: InkWell(
            onTap: _showFilterSheet,
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.tune_rounded,
                size: 20,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ),
        if (count > 0)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              width: 17,
              height: 17,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildYearSelector(List<int> availableYears, bool isDark) {
    final accent = isDark ? AppColors.primaryLight : AppColors.primary;

    return Material(
      color: AppColors.surface(isDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderSoftLight,
        ),
      ),
      child: InkWell(
        onTap: () => _showYearPickerSheet(availableYears, isDark),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today_rounded, size: 14, color: accent),
              const SizedBox(width: 6),
              Text('$_selectedYear', style: AppTypography.sectionAction(isDark)),
              const SizedBox(width: 2),
              Icon(Icons.unfold_more_rounded, size: 16, color: accent),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Year picker sheet
  // ---------------------------------------------------------------------------

  void _showYearPickerSheet(List<int> availableYears, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface(isDark),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _grabHandle(isDark),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Select Year', style: AppTypography.sectionTitle(isDark)),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              Divider(color: AppColors.dividerSoft(isDark)),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: availableYears.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final year = availableYears[index];
                    final isSelected = year == _selectedYear;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() => _selectedYear = year);
                          Navigator.of(ctx).pop();
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            border: isSelected
                                ? Border.all(
                                    color: AppColors.primary,
                                    width: 1.2,
                                  )
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$year',
                                style: AppTypography.listTitle(isDark).copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.primary
                                      : null,
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _grabHandle(bool isDark) => Container(
    width: 36,
    height: 4,
    decoration: BoxDecoration(
      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(2),
    ),
  );

  // ---------------------------------------------------------------------------
  // Filter sheet (leave type, date range, status)
  // ---------------------------------------------------------------------------

  Future<DateTime?> _pickDate(BuildContext ctx, DateTime? initial) async {
    final controller = TextEditingController(
      text: (initial ?? DateTime.now()).toIso8601String().split('T').first,
    );
    try {
      return await showCustomCupertinoDatePicker(
        context: ctx,
        controller: controller,
        minDate: DateTime(2020),
        maxDate: DateTime.now().add(const Duration(days: 365)),
      );
    } finally {
      controller.dispose();
    }
  }

  void _showFilterSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Working copies, only applied when "Apply Filter" is pressed.
    var type = _typeFilter;
    var status = _statusFilter;
    var start = _startDate;
    var end = _endDate;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            Widget label(String text) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                text,
                style: AppTypography.listMeta(
                  isDark,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            );

            return Container(
              decoration: BoxDecoration(
                color: AppColors.surface(isDark),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                16 + MediaQuery.of(ctx).padding.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: _grabHandle(isDark)),
                    const SizedBox(height: 14),

                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(
                              alpha: isDark ? 0.2 : 0.09,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'FILTER',
                            style: AppTypography.heroChip(
                              isDark
                                  ? AppColors.primaryLight
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Leave type
                    label('Leave type'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _FilterChipButton(
                          label: 'All',
                          selected: type == null,
                          onTap: () => setSheet(() => type = null),
                        ),
                        for (final t in LeaveType.values)
                          _FilterChipButton(
                            label: t.label,
                            selected: type == t,
                            onTap: () => setSheet(() => type = t),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Date range
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              label('Start Date'),
                              _DateField(
                                value: start,
                                hint: 'Select date',
                                onTap: () async {
                                  final picked = await _pickDate(ctx, start);
                                  if (picked == null) return;
                                  setSheet(() {
                                    start = _dateOnly(picked);
                                    if (end != null && end!.isBefore(start!)) {
                                      end = null;
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              label('End Date'),
                              _DateField(
                                value: end,
                                hint: 'Select date',
                                onTap: () async {
                                  final picked = await _pickDate(
                                    ctx,
                                    end ?? start,
                                  );
                                  if (picked == null) return;
                                  setSheet(() {
                                    final d = _dateOnly(picked);
                                    end = (start != null && d.isBefore(start!))
                                        ? start
                                        : d;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Status
                    label('Status'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final s in _statusOptions)
                          _FilterChipButton(
                            label: s,
                            selected: status == s,
                            onTap: () => setSheet(() => status = s),
                          ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Divider(height: 1, color: AppColors.dividerSoft(isDark)),
                    const SizedBox(height: 16),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: _SheetButton(
                            label: 'Clear All',
                            filled: false,
                            onTap: () {
                              setState(() {
                                _typeFilter = null;
                                _statusFilter = 'All';
                                _startDate = null;
                                _endDate = null;
                              });
                              Navigator.of(ctx).pop();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: _SheetButton(
                            label: 'Apply Filter',
                            filled: true,
                            onTap: () {
                              setState(() {
                                _typeFilter = type;
                                _statusFilter = status;
                                _startDate = start;
                                _endDate = end;
                              });
                              Navigator.of(ctx).pop();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// =============================================================================
// SMALL PRIVATE WIDGETS
// =============================================================================

class _FilterChipButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.primaryLight : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.09)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.035)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? accent : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected
                ? accent
                : (isDark
                      ? AppColors.textMutedDark
                      : AppColors.textSecondaryLight),
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final DateTime? value;
  final String hint;
  final VoidCallback onTap;

  const _DateField({
    required this.value,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderSoftLight,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value == null ? hint : formatLeaveDate(value!),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.listTitle(isDark).copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: value == null
                        ? (isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight)
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.calendar_today_rounded,
                size: 15,
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _SheetButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: filled
          ? AppColors.primary
          : (isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.045)),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: filled
                  ? Colors.white
                  : (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textSecondaryLight),
            ),
          ),
        ),
      ),
    );
  }
}