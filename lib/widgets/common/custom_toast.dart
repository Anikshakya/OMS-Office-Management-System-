import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'ui_glass_container.dart';

class ToastOverlayRenderer extends StatelessWidget {
  final List<ToastNotification> toasts;
  final ValueChanged<String> onDismiss;

  const ToastOverlayRenderer({
    super.key,
    required this.toasts,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (toasts.isEmpty) return const SizedBox.shrink();

    final topPadding = MediaQuery.of(context).padding.top + 12;

    return Positioned(
      top: topPadding,
      right: 16,
      left: MediaQuery.of(context).size.width > 600 ? null : 16,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: toasts.map((toast) {
            Color color;
            IconData icon;

            switch (toast.type) {
              case ToastType.success:
                color = AppColors.success;
                icon = Icons.check_circle_rounded;
                break;
              case ToastType.error:
                color = AppColors.error;
                icon = Icons.error_rounded;
                break;
              case ToastType.warning:
                color = AppColors.warning;
                icon = Icons.warning_rounded;
                break;
              case ToastType.info:
                color = AppColors.info;
                icon = Icons.info_rounded;
                break;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, -24 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: GlassContainer(
                  borderRadius: 14,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: color, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              toast.title,
                              style: AppTypography.labelLarge(isDark).copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              toast.message,
                              style: AppTypography.caption(isDark).copyWith(
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => onDismiss(toast.id),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
