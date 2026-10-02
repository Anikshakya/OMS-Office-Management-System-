import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

enum AppButtonVariant { primary, secondary, outlined, text }

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
    this.borderRadius = 12.0,
  });

  const AppButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
    this.borderRadius = 12.0,
  }) : variant = AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
    this.borderRadius = 12.0,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
    this.borderRadius = 12.0,
  }) : variant = AppButtonVariant.outlined;

  const AppButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
    this.borderRadius = 12.0,
  }) : variant = AppButtonVariant.text;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDisabled = widget.onPressed == null || widget.isLoading;

    Color bg;
    Color fg;
    BorderSide border = BorderSide.none;

    switch (widget.variant) {
      case AppButtonVariant.primary:
        bg = isDisabled
            ? (isDark ? AppColors.borderDark : AppColors.borderLight)
            : (_isHovered ? AppColors.primaryLight : AppColors.primary);
        fg = Colors.white;
        break;
      case AppButtonVariant.secondary:
        bg = isDisabled
            ? (isDark ? AppColors.borderDark : AppColors.borderLight)
            : (isDark
                ? (_isHovered ? AppColors.cardDark : AppColors.surfaceDark)
                : (_isHovered ? AppColors.borderLight : AppColors.primaryContainer));
        fg = isDark ? AppColors.textPrimaryDark : AppColors.primary;
        break;
      case AppButtonVariant.outlined:
        bg = _isHovered
            ? (isDark ? AppColors.borderDark.withValues(alpha: 0.5) : AppColors.primaryContainer.withValues(alpha: 0.4))
            : Colors.transparent;
        fg = isDark ? AppColors.textPrimaryDark : AppColors.primary;
        border = BorderSide(
          color: isDisabled
              ? (isDark ? AppColors.borderDark : AppColors.borderLight)
              : (_isHovered ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.borderLight)),
          width: 1.2,
        );
        break;
      case AppButtonVariant.text:
        bg = _isHovered
            ? (isDark ? AppColors.borderDark.withValues(alpha: 0.3) : AppColors.primaryContainer.withValues(alpha: 0.3))
            : Colors.transparent;
        fg = isDark ? AppColors.textPrimaryDark : AppColors.primary;
        break;
    }

    final defaultPadding = widget.padding ??
        const EdgeInsets.symmetric(horizontal: 16, vertical: 11);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: isDisabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: widget.isFullWidth ? double.infinity : null,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: border != BorderSide.none ? Border.all(color: border.color, width: border.width) : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isDisabled ? null : widget.onPressed,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: Padding(
                  padding: defaultPadding,
                  child: Row(
                    mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.isLoading) ...[
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(fg),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ] else if (widget.icon != null) ...[
                        Icon(widget.icon, size: 16, color: fg),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(
                          widget.label,
                          style: AppTypography.labelLarge(isDark).copyWith(
                            color: fg,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final Color? iconColor;
  final double size;
  final double borderRadius;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
    this.iconColor,
    this.size = 36,
    this.borderRadius = 10,
  });

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = widget.color ??
        (_isHovered
            ? (isDark ? AppColors.cardDark : AppColors.borderLight)
            : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight));

    final iconColor = widget.iconColor ??
        (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    final button = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onPressed != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Icon(
              widget.icon,
              size: widget.size * 0.52,
              color: iconColor,
            ),
          ),
        ),
      ),
    );

    return widget.tooltip != null ? Tooltip(message: widget.tooltip!, child: button) : button;
  }
}
