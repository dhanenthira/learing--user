import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';

class AppCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final bool isElevated;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.width,
    this.height,
    this.isElevated = false,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color defaultBg = isDark
        ? (widget.isElevated ? AppColors.surfaceElevated : AppColors.surface)
        : (widget.isElevated ? AppColors.lightSurfaceElevated : AppColors.lightSurface);

    Color defaultBorder = isDark ? AppColors.border : AppColors.lightBorder;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        width: widget.width,
        height: widget.height,
        padding: widget.padding ?? const EdgeInsets.all(AppSpacing.space5),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? (_isHovered && widget.onTap != null && isDark ? AppColors.surfaceHover : defaultBg),
          borderRadius: AppRadii.cardStandardRadius,
          border: Border.all(
            color: _isHovered && widget.onTap != null ? AppColors.primary : (widget.borderColor ?? defaultBorder),
            width: 1,
          ),
          boxShadow: widget.isElevated
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.35 : 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: AppRadii.cardStandardRadius,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final String? subtitle;
  final double? progress;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.subtitle,
    this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final mutedTextColor = isDark ? AppColors.textMuted : AppColors.lightTextMuted;
    final progressTrackColor = isDark ? AppColors.border : AppColors.lightBorder;

    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: AppRadii.inputRadius,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              if (subtitle != null)
                Flexible(
                  child: Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: subtitle!.startsWith('+') ? AppColors.success : mutedTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.space3),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: mutedTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.space1),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: primaryTextColor,
              letterSpacing: -0.5,
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: AppSpacing.space2),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: progressTrackColor,
                valueColor: AlwaysStoppedAnimation<Color>(iconColor),
              ),
            ),
          ]
        ],
      ),
    );
  }
}

