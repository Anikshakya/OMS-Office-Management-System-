import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class GlassContainer extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? color;
  final Color? borderColor;
  final double blur;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.width,
    this.height,
    this.color,
    this.borderColor,
    this.blur = 16.0,
    this.onTap,
  });

  @override
  State<GlassContainer> createState() => _GlassContainerState();
}

class _GlassContainerState extends State<GlassContainer> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultGlassColor = isDark
        ? AppColors.cardDark.withValues(alpha: 0.75)
        : AppColors.surfaceLight.withValues(alpha: 0.85);

    final defaultBorderColor = isDark
        ? AppColors.borderDark
        : AppColors.borderLight;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: widget.width,
        height: widget.height,
        margin: widget.margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: _isHovered ? AppColors.hoverShadow(isDark) : AppColors.softShadow(isDark),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                splashColor: AppColors.primary.withValues(alpha: 0.08),
                highlightColor: Colors.transparent,
                child: Container(
                  padding: widget.padding,
                  decoration: BoxDecoration(
                    color: widget.color ?? defaultGlassColor,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    border: Border.all(
                      color: widget.borderColor ?? (_isHovered ? AppColors.primary.withValues(alpha: 0.4) : defaultBorderColor),
                      width: 1,
                    ),
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
