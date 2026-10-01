import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class AppCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String? label;

  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: value ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.borderLight),
                  width: 1.8,
                ),
              ),
              child: value
                  ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                  : null,
            ),
            if (label != null) ...[
              const SizedBox(width: 10),
              Text(
                label!,
                style: AppTypography.bodyLarge(isDark),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? label;
  final IconData? activeIcon;
  final IconData? inactiveIcon;

  const AppSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.activeIcon,
    this.inactiveIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 48,
            height: 28,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: value
                  ? AppColors.primary
                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: (value && activeIcon != null)
                    ? Icon(activeIcon, size: 14, color: AppColors.primary)
                    : (!value && inactiveIcon != null)
                        ? Icon(inactiveIcon, size: 14, color: AppColors.textSecondaryLight)
                        : null,
              ),
            ),
          ),
          if (label != null) ...[
            const SizedBox(width: 10),
            Text(
              label!,
              style: AppTypography.labelLarge(isDark),
            ),
          ],
        ],
      ),
    );
  }
}

class AppChipSelect<T> extends StatelessWidget {
  final List<T> options;
  final T selectedValue;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onSelected;

  const AppChipSelect({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.labelBuilder,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = option == selectedValue;

        return ChoiceChip(
          label: Text(labelBuilder(option)),
          selected: isSelected,
          onSelected: (_) => onSelected(option),
          labelStyle: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
          ),
          selectedColor: AppColors.primary,
          backgroundColor: isDark ? AppColors.cardDark : AppColors.surfaceLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
              width: 1,
            ),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        );
      }).toList(),
    );
  }
}
