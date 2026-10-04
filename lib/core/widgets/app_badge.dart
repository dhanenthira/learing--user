import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';

class AppBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? textColor;
  final IconData? icon;
  final bool isPill;

  const AppBadge({
    super.key,
    required this.label,
    this.color,
    this.textColor,
    this.icon,
    this.isPill = false,
  });

  factory AppBadge.difficulty(String difficulty) {
    Color bg;
    Color text;
    String clean = difficulty.toLowerCase().trim();

    if (clean == 'easy') {
      bg = AppColors.success.withOpacity(0.15);
      text = AppColors.success;
    } else if (clean == 'medium') {
      bg = AppColors.warning.withOpacity(0.15);
      text = AppColors.warning;
    } else {
      bg = AppColors.error.withOpacity(0.15);
      text = AppColors.error;
    }

    return AppBadge(
      label: difficulty.toUpperCase(),
      color: bg,
      textColor: text,
      isPill: true,
    );
  }

  factory AppBadge.streak(int days) {
    return AppBadge(
      label: "$days Day Streak",
      color: AppColors.streak.withOpacity(0.15),
      textColor: AppColors.streak,
      icon: Icons.local_fire_department,
      isPill: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.surfaceElevated;
    final effectiveTextColor = textColor ?? AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: isPill ? BorderRadius.circular(20) : AppRadii.badgeRadius,
        border: Border.all(
          color: effectiveTextColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: effectiveTextColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: effectiveTextColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
