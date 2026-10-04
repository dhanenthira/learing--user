import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_typography.dart';

enum AppButtonVariant { primary, secondary, destructive, text, outline }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 44.0,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case AppButtonVariant.primary:
        bgColor = AppColors.primary;
        textColor = AppColors.textOnPrimary;
        break;
      case AppButtonVariant.secondary:
        bgColor = AppColors.surfaceElevated;
        textColor = AppColors.textPrimary;
        borderSide = const BorderSide(color: AppColors.border, width: 1);
        break;
      case AppButtonVariant.destructive:
        bgColor = AppColors.error;
        textColor = AppColors.textOnPrimary;
        break;
      case AppButtonVariant.outline:
        bgColor = Colors.transparent;
        textColor = AppColors.primary;
        borderSide = const BorderSide(color: AppColors.primary, width: 1.5);
        break;
      case AppButtonVariant.text:
        bgColor = Colors.transparent;
        textColor = AppColors.primary;
        break;
    }

    Widget content = Row(
      mainAxisSize: width == null ? MainAxisSize.min : MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          )
        else ...[
          if (icon != null) ...[
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: AppTypography.button(context, color: textColor),
          ),
        ]
      ],
    );

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: onPressed == null ? AppColors.surfaceHover.withOpacity(0.5) : bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.buttonRadius,
          side: borderSide,
        ),
        child: InkWell(
          onTap: (isLoading || onPressed == null) ? null : onPressed,
          borderRadius: AppRadii.buttonRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: content,
          ),
        ),
      ),
    );
  }
}

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final String? tooltip;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.backgroundColor,
    this.size = 40.0,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceElevated,
        borderRadius: AppRadii.inputRadius,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppRadii.inputRadius,
          child: Center(
            child: Icon(
              icon,
              size: size * 0.5,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
